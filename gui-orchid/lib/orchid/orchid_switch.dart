// @dart=2.9
import 'package:orchid/orchid/orchid.dart';

class OrchidSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const OrchidSwitch({
    Key key,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: OrchidColors.switch_active_thumb,
      activeTrackColor: OrchidColors.switch_active_track,
      inactiveThumbColor: OrchidColors.switch_inactive_thumb,
      inactiveTrackColor: OrchidColors.switch_inactive_track,
      value: value,
      onChanged: onChanged,
    );
  }
}
