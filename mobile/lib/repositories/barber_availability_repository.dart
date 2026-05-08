import '../models/availability_models.dart';
import '../services/supabase_config.dart';

class BarberAvailabilityRepository {
  const BarberAvailabilityRepository();

  Future<List<ClosureDay>> getClosures({required String barberId}) async {
    final rows = await SupabaseConfig.client
        .from('barber_closures')
        .select('id, closure_date, reason')
        .eq('barber_id', barberId)
        .order('closure_date');

    return rows.map<ClosureDay>((row) {
      return ClosureDay(
        id: row['id'].toString(),
        dateLabel: _formatDateLabel(row['closure_date']),
        reason: _cleanReason(row['reason']),
      );
    }).toList();
  }

  Future<List<TimeBlock>> getTimeBlocks({required String barberId}) async {
    final rows = await SupabaseConfig.client
        .from('barber_time_blocks')
        .select('id, block_type, block_date, start_time, end_time, reason')
        .eq('barber_id', barberId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return rows.map<TimeBlock>((row) {
      final blockType = (row['block_type'] ?? '').toString();
      final blockDate = row['block_date'];

      return TimeBlock(
        id: row['id'].toString(),
        type: blockType,
        dateLabel: blockType == 'specific' ? _formatDateLabel(blockDate) : null,
        startTime: _cleanTime(row['start_time']),
        endTime: _cleanTime(row['end_time']),
        reason: _cleanReason(row['reason']),
      );
    }).toList();
  }

  Future<ClosureDay> addClosure({
    required String barberId,
    required DateTime closureDate,
    required String reason,
  }) async {
    final row = await SupabaseConfig.client
        .from('barber_closures')
        .upsert({
          'barber_id': barberId,
          'closure_date': _dateForDatabase(closureDate),
          'reason': reason.trim().isEmpty ? 'بدون سبب مذكور' : reason.trim(),
        }, onConflict: 'barber_id,closure_date')
        .select('id, closure_date, reason')
        .single();

    return ClosureDay(
      id: row['id'].toString(),
      dateLabel: _formatDateLabel(row['closure_date']),
      reason: _cleanReason(row['reason']),
    );
  }

  Future<ClosureDay> updateClosure({required ClosureDay closure}) async {
    final row = await SupabaseConfig.client
        .from('barber_closures')
        .update({
          'closure_date': _dateStringForDatabase(closure.dateLabel),
          'reason': closure.reason.trim().isEmpty
              ? 'بدون سبب مذكور'
              : closure.reason.trim(),
        })
        .eq('id', closure.id)
        .select('id, closure_date, reason')
        .single();

    return ClosureDay(
      id: row['id'].toString(),
      dateLabel: _formatDateLabel(row['closure_date']),
      reason: _cleanReason(row['reason']),
    );
  }

  Future<void> deleteClosure({required String closureId}) async {
    await SupabaseConfig.client
        .from('barber_closures')
        .delete()
        .eq('id', closureId);
  }

  Future<TimeBlock> addTimeBlock({
    required String barberId,
    required String blockType,
    required DateTime? blockDate,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    final row = await SupabaseConfig.client
        .from('barber_time_blocks')
        .insert({
          'barber_id': barberId,
          'block_type': blockType,
          'block_date': blockType == 'specific' && blockDate != null
              ? _dateForDatabase(blockDate)
              : null,
          'start_time': _timeForDatabase(startTime),
          'end_time': _timeForDatabase(endTime),
          'reason': reason.trim().isEmpty ? 'بدون سبب مذكور' : reason.trim(),
          'is_active': true,
        })
        .select('id, block_type, block_date, start_time, end_time, reason')
        .single();

    return _mapTimeBlock(row);
  }

  Future<TimeBlock> updateTimeBlock({required TimeBlock block}) async {
    final row = await SupabaseConfig.client
        .from('barber_time_blocks')
        .update({
          'block_type': block.type,
          'block_date': block.type == 'specific' && block.dateLabel != null
              ? _dateStringForDatabase(block.dateLabel!)
              : null,
          'start_time': _timeForDatabase(block.startTime),
          'end_time': _timeForDatabase(block.endTime),
          'reason': block.reason.trim().isEmpty
              ? 'بدون سبب مذكور'
              : block.reason.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', block.id)
        .select('id, block_type, block_date, start_time, end_time, reason')
        .single();

    return _mapTimeBlock(row);
  }

  Future<void> deleteTimeBlock({required String blockId}) async {
    await SupabaseConfig.client
        .from('barber_time_blocks')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', blockId);
  }

  TimeBlock _mapTimeBlock(Map<String, dynamic> row) {
    final blockType = (row['block_type'] ?? '').toString();
    final blockDate = row['block_date'];

    return TimeBlock(
      id: row['id'].toString(),
      type: blockType,
      dateLabel: blockType == 'specific' ? _formatDateLabel(blockDate) : null,
      startTime: _cleanTime(row['start_time']),
      endTime: _cleanTime(row['end_time']),
      reason: _cleanReason(row['reason']),
    );
  }

  String _cleanReason(dynamic value) {
    final cleaned = value?.toString().trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'بدون سبب مذكور';
    }

    return cleaned;
  }

  String _cleanTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty) {
      return '09:00';
    }

    final parts = raw.split(':');
    final hour = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '09';
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';

    return '$hour:$minute';
  }

  String _timeForDatabase(String value) {
    return '${_cleanTime(value)}:00';
  }

  String _dateForDatabase(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _dateStringForDatabase(String dateLabel) {
    final parts = dateLabel.split('/');

    if (parts.length != 3) {
      return dateLabel;
    }

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2].padLeft(4, '0');

    return '$year-$month-$day';
  }

  String _formatDateLabel(dynamic value) {
    if (value == null) {
      return '';
    }

    final parsed = DateTime.tryParse(value.toString());

    if (parsed == null) {
      return value.toString();
    }

    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
