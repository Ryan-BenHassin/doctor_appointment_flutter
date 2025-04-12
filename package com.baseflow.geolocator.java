package com.baseflow.geolocator.location;

import android.location.Location;

import java.util.HashMap;
import java.util.Map;

class LocationMapper {
  static Map<String, Object> toHashMap(Location location) {
    if (location == null) {
      return null;
    }

    Map<String, Object> position = new HashMap<>();
    position.put("latitude", location.getLatitude());
    position.put("longitude", location.getLongitude());
    position.put("timestamp", location.getTime());
    position.put("altitude", location.getAltitude());
    position.put("accuracy", (double) location.getAccuracy());
    position.put("speed", (double) location.getSpeed());
    position.put("speed_accuracy", location.hasSpeedAccuracy() ? (double) location.getSpeedAccuracyMetersPerSecond() : null);
    position.put("heading", (double) location.getBearing());
    position.put("heading_accuracy", location.hasBearingAccuracy() ? (double) location.getBearingAccuracyDegrees() : null);
    position.put("is_mocked", location.isFromMockProvider());

    return position;
  }
}