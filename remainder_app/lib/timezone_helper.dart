import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void initializeTimeZones() {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Detroit')); // Adjust to your local timezone
}
