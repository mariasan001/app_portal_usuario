import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import 'mis_citas_ui.dart';

enum SlotEstado { disponible, ocupado, bloqueado }

class CitaSeleccionResult {
  const CitaSeleccionResult(this.fechaHora);
  final DateTime fechaHora;
}

class CitaSelectorSheet extends StatefulWidget {
  const CitaSelectorSheet({
    super.key,
    required this.accent,
    required this.initial,
    this.daysWindow = 21,
  });

  final Color accent;
  final DateTime initial;
  final int daysWindow;

  static Future<CitaSeleccionResult?> open(
    BuildContext context, {
    required Color accent,
    required DateTime initial,
    int daysWindow = 21,
  }) {
    return showModalBottomSheet<CitaSeleccionResult?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: ColoresApp.blanco,
      barrierColor: Colors.black.withOpacity(0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CitaSelectorSheet(
          accent: accent,
          initial: initial,
          daysWindow: daysWindow,
        ),
      ),
    );
  }

  @override
  State<CitaSelectorSheet> createState() => _CitaSelectorSheetState();
}

class _CitaSelectorSheetState extends State<CitaSelectorSheet> {
  late DateTime _selectedDay;
  TimeOfDay? _selectedTime;

  late final Set<DateTime> _occupiedDays;
  late final Set<DateTime> _blockedDays;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateUtils.dateOnly(widget.initial);

    _occupiedDays = {
      DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1))),
      DateUtils.dateOnly(DateTime.now().add(const Duration(days: 4))),
      DateUtils.dateOnly(DateTime.now().add(const Duration(days: 8))),
    };

    _blockedDays = {
      // puedes llenar por API luego
    };
  }

  SlotEstado _estadoDia(DateTime d) {
    final day = DateUtils.dateOnly(d);
    final wd = day.weekday;

    final isWeekend = wd == DateTime.saturday || wd == DateTime.sunday;
    if (isWeekend) return SlotEstado.bloqueado;

    if (_blockedDays.contains(day)) return SlotEstado.bloqueado;
    if (_occupiedDays.contains(day)) return SlotEstado.ocupado;

    return SlotEstado.disponible;
  }

  List<DateTime> _daysList() {
    final start = DateUtils.dateOnly(DateTime.now());
    return List.generate(widget.daysWindow, (i) => start.add(Duration(days: i)));
  }

  List<TimeOfDay> _timeSlotsFor(DateTime day) {
    // Mock: 10:00 - 14:00 cada 30 mins
    const startHour = 10;
    const endHour = 14;
    final slots = <TimeOfDay>[];

    for (int h = startHour; h <= endHour; h++) {
      slots.add(TimeOfDay(hour: h, minute: 0));
      if (h != endHour) slots.add(TimeOfDay(hour: h, minute: 30));
    }
    return slots;
  }

  bool _timeOccupied(DateTime day, TimeOfDay t) {
    // Mock: algunas horas ocupadas
    final key = '${day.year}-${day.month}-${day.day}-${t.hour}-${t.minute}';
    return key.hashCode % 7 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = widget.accent;

    final days = _daysList();
    final dayState = _estadoDia(_selectedDay);
    final timeSlots = dayState == SlotEstado.disponible ? _timeSlotsFor(_selectedDay) : <TimeOfDay>[];

    final canConfirm = dayState == SlotEstado.disponible && _selectedTime != null;

    final w = MediaQuery.of(context).size.width;
    final compact = w < 380;

    final gridSpacing = compact ? 8.0 : 10.0;
    final gridRatio = compact ? 0.72 : 0.78; // ✅ más altura cuando es compacto

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) {
        return SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ColoresApp.bordeSuave,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: a.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: a.withOpacity(0.22)),
                    ),
                    child: Icon(PhosphorIconsRegular.calendarPlus, color: a, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona tu cita',
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                          ),
                        ),
                        Text(
                          'Día y hora (tipo asientos)',
                          style: t.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ColoresApp.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(PhosphorIconsRegular.x, color: ColoresApp.texto),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _LegendDot(label: 'Disponible', state: SlotEstado.disponible, accent: a),
                  _LegendDot(label: 'Ocupado', state: SlotEstado.ocupado, accent: a),
                  _LegendDot(label: 'Bloqueado', state: SlotEstado.bloqueado, accent: a),
                  _LegendDot(label: 'Seleccionado', state: null, accent: a),
                ],
              ),

              const SizedBox(height: 14),
              Text(
                'Elige un día',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                  childAspectRatio: gridRatio,
                ),
                itemBuilder: (ctx, i) {
                  final d = days[i];
                  final s = _estadoDia(d);
                  final selected = DateUtils.isSameDay(d, _selectedDay);

                  final disabled = s != SlotEstado.disponible;

                  final bg = selected
                      ? a
                      : (disabled ? ColoresApp.inputBg : ColoresApp.blanco);

                  final bd = selected ? a : ColoresApp.bordeSuave;

                  final fgMain = selected ? ColoresApp.blanco : ColoresApp.texto;
                  final fgSub = selected ? ColoresApp.blanco : ColoresApp.textoSuave;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: disabled
                        ? null
                        : () {
                            setState(() {
                              _selectedDay = DateUtils.dateOnly(d);
                              _selectedTime = null;
                            });
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: bd),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: _DayCellContent(
                          day: d,
                          state: s,
                          selected: selected,
                          accent: a,
                          fgMain: fgMain,
                          fgSub: fgSub,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),
              Text(
                'Elige una hora',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const SizedBox(height: 10),

              if (dayState != SlotEstado.disponible)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: ColoresApp.inputBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColoresApp.bordeSuave),
                  ),
                  child: Text(
                    dayState == SlotEstado.ocupado
                        ? 'Ese día ya está ocupado. Elige otro.'
                        : 'Sábados y domingos no hay atención (mock).',
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.textoSuave,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final slot in timeSlots)
                      _TimeChip(
                        accent: a,
                        time: slot,
                        selected: _selectedTime != null &&
                            _selectedTime!.hour == slot.hour &&
                            _selectedTime!.minute == slot.minute,
                        occupied: _timeOccupied(_selectedDay, slot),
                        onTap: () {
                          if (_timeOccupied(_selectedDay, slot)) return;
                          setState(() => _selectedTime = slot);
                        },
                      ),
                  ],
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: UiSecondaryButton(
                      text: 'Cancelar',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UiPrimaryButton(
                      text: 'Confirmar',
                      accent: a,
                      enabled: canConfirm,
                      onTap: () {
                        final time = _selectedTime!;
                        final dt = DateTime(
                          _selectedDay.year,
                          _selectedDay.month,
                          _selectedDay.day,
                          time.hour,
                          time.minute,
                        );
                        Navigator.pop(context, CitaSeleccionResult(dt));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayCellContent extends StatelessWidget {
  const _DayCellContent({
    required this.day,
    required this.state,
    required this.selected,
    required this.accent,
    required this.fgMain,
    required this.fgSub,
  });

  final DateTime day;
  final SlotEstado state;
  final bool selected;
  final Color accent;
  final Color fgMain;
  final Color fgSub;

  IconData _stateIcon() {
    switch (state) {
      case SlotEstado.ocupado:
        return PhosphorIconsRegular.xCircle;
      case SlotEstado.bloqueado:
        return PhosphorIconsRegular.lock;
      case SlotEstado.disponible:
        return PhosphorIconsRegular.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (ctx, c) {
        final h = c.maxHeight;

        // ✅ tamaños proporcionales: evita overflow en TODOS los tamaños
        final dowSize = (h * 0.22).clamp(8.0, 11.0);
        final daySize = (h * 0.38).clamp(12.0, 18.0);
        final iconSize = (h * 0.22).clamp(10.0, 16.0);
        final gap = (h * 0.06).clamp(2.0, 6.0);

        Widget bottom() {
          if (selected) {
            return Icon(PhosphorIconsFill.checkCircle, size: iconSize, color: ColoresApp.blanco);
          }
          if (state == SlotEstado.disponible) {
            // puntito, más barato y sin overflow
            return Container(
              width: iconSize * 0.55,
              height: iconSize * 0.55,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
            );
          }
          return Icon(_stateIcon(), size: iconSize, color: fgSub);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                fmtDiaCorto(day.weekday),
                style: tt.bodySmall?.copyWith(
                  fontSize: dowSize,
                  fontWeight: FontWeight.w900,
                  color: fgSub,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(height: gap),
            Text(
              fmt2(day.day),
              style: tt.titleMedium?.copyWith(
                fontSize: daySize,
                fontWeight: FontWeight.w900,
                color: fgMain,
                height: 1.0,
              ),
            ),
            SizedBox(height: gap),
            bottom(),
          ],
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.state, required this.accent});

  final String label;
  final SlotEstado? state;
  final Color accent;

  Color _dot() {
    if (state == null) return accent; // seleccionado
    switch (state!) {
      case SlotEstado.disponible:
        return accent.withOpacity(0.85);
      case SlotEstado.ocupado:
        return ColoresApp.textoSuave;
      case SlotEstado.bloqueado:
        return ColoresApp.bordeSuave;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _dot(), shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: t.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: ColoresApp.textoSuave,
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.accent,
    required this.time,
    required this.selected,
    required this.occupied,
    required this.onTap,
  });

  final Color accent;
  final TimeOfDay time;
  final bool selected;
  final bool occupied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ml = MaterialLocalizations.of(context);

    final label = ml.formatTimeOfDay(time, alwaysUse24HourFormat: true);

    final bg = selected
        ? accent
        : occupied
            ? ColoresApp.inputBg
            : ColoresApp.blanco;

    final bd = selected ? accent : ColoresApp.bordeSuave;

    final fg = selected
        ? ColoresApp.blanco
        : (occupied ? ColoresApp.textoSuave : ColoresApp.texto);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: occupied ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: bd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (occupied) ...[
              Icon(PhosphorIconsRegular.prohibit, size: 16, color: ColoresApp.textoSuave),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
