pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

import qs.modules.common

Singleton {
    id: root

    readonly property bool enabled: Config.options?.bar?.weather?.enable ?? false
    readonly property int fetchInterval: (Config.options?.bar?.weather?.fetchInterval ?? 10) * 60 * 1000
    readonly property string city: Config.options?.bar?.weather?.city ?? ""
    readonly property bool useUSCS: Config.options?.bar?.weather?.useUSCS ?? false
    property bool gpsActive: Config.options?.bar?.weather?.enableGPS ?? false

    onEnabledChanged: {
        if (root.enabled) {
            Qt.callLater(() => root.getData())
        }
    }

    onUseUSCSChanged: root.getData()
    onCityChanged: root._geocodeCity()

    property var location: ({ valid: false, lat: 0, lon: 0, name: "" })

    property var data: ({
        uv: "0",
        humidity: "0%",
        sunrise: "--:--",
        sunriseIso: "",
        sunset: "--:--",
        sunsetIso: "",
        windDir: "N",
        wCode: "0",
        city: "City",
        wind: "0 km/h",
        precip: "0 mm",
        visib: "10 km",
        press: "1013 hPa",
        temp: "--°C",
        tempFeelsLike: "--°C"
    })

    function isNightNow(): bool {
        const now = new Date();

        const sunriseIso = root.data?.sunriseIso ?? "";
        const sunsetIso = root.data?.sunsetIso ?? "";
        if (sunriseIso.length > 0 && sunsetIso.length > 0) {
            const sunrise = new Date(sunriseIso);
            const sunset = new Date(sunsetIso);
            if (!isNaN(sunrise.getTime()) && !isNaN(sunset.getTime())) {
                return now < sunrise || now > sunset;
            }
        }

        const h = now.getHours();
        return h < 6 || h >= 18;
    }

    // WMO Weather codes to wttr.in codes (for icon compatibility)
    function _wmoToWttr(code: int): string {
        const map = {
            "0": "113",    // Clear sky
            "1": "116", "2": "116", "3": "119",  // Partly cloudy, cloudy
            "45": "143", "48": "143",  // Fog
            "51": "266", "53": "266", "55": "266",  // Drizzle
            "56": "281", "57": "281",  // Freezing drizzle
            "61": "296", "63": "302", "65": "308",  // Rain
            "66": "311", "67": "314",  // Freezing rain
            "71": "326", "73": "329", "75": "332",  // Snow
            "77": "350",  // Snow grains
            "80": "353", "81": "356", "82": "359",  // Rain showers
            "85": "368", "86": "371",  // Snow showers
            "95": "386",  // Thunderstorm
            "96": "389", "99": "395"   // Thunderstorm with hail
        };
        return map[String(code)] ?? "113";
    }

    function _degToCompass(deg: real): string {
        const dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        return dirs[Math.round(deg / 22.5) % 16];
    }

    function _formatTime(isoTime: string): string {
        if (!isoTime) return "--:--";
        const date = new Date(isoTime);
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
    }

    function _refineData(apiData: var): void {
        const current = apiData?.current;
        const daily = apiData?.daily;
        if (!current) return;

        let result = {};
        const wmoCode = current.weather_code ?? 0;
        result.wCode = root._wmoToWttr(wmoCode);
        result.city = root.location.name || root.city || "Unknown";
        result.humidity = (current.relative_humidity_2m ?? 0) + "%";
        result.windDir = root._degToCompass(current.wind_direction_10m ?? 0);
        result.press = Math.round(current.surface_pressure ?? 1013) + " hPa";
        result.uv = daily?.uv_index_max?.[0]?.toFixed(1) ?? "0";
        result.sunriseIso = daily?.sunrise?.[0] ?? "";
        result.sunsetIso = daily?.sunset?.[0] ?? "";
        result.sunrise = root._formatTime(result.sunriseIso);
        result.sunset = root._formatTime(result.sunsetIso);

        // Visibility not available in Open-Meteo free tier, use placeholder
        result.visib = "10 km";
        // Precipitation - current doesn't have it, would need hourly
        result.precip = "0 mm";

        if (root.useUSCS) {
            const tempF = Math.round((current.temperature_2m ?? 0) * 9/5 + 32);
            const feelsF = Math.round((current.apparent_temperature ?? 0) * 9/5 + 32);
            const windMph = Math.round((current.wind_speed_10m ?? 0) * 0.621371);
            result.temp = tempF + "°F";
            result.tempFeelsLike = feelsF + "°F";
            result.wind = windMph + " mph";
            result.press = Math.round((current.surface_pressure ?? 1013) * 0.02953) + " inHg";
        } else {
            result.temp = Math.round(current.temperature_2m ?? 0) + "°C";
            result.tempFeelsLike = Math.round(current.apparent_temperature ?? 0) + "°C";
            result.wind = Math.round(current.wind_speed_10m ?? 0) + " km/h";
        }

        root.data = result;
    }

    function _geocodeCity(): void {
        if (!root.city || root.city.length === 0) {
            root._fetchByIP();
            return;
        }
        const cleanCity = root.city.replace(/[\r\n]+/g, '').trim();
        const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cleanCity)}&count=1&language=en&format=json`;
        geocoder.command = ["curl", "-s", "--max-time", "10", url];
        geocoder.running = true;
    }

    function _fetchByIP(): void {
        // Use ip-api.com to get location from IP
        ipLocator.running = true;
    }

    function getData(): void {
        if (!root.location.valid) {
            root._geocodeCity();
            return;
        }

        const lat = root.location.lat;
        const lon = root.location.lon;
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure&daily=sunrise,sunset,uv_index_max&timezone=auto`;

        fetcher.command = ["curl", "-s", "--max-time", "10", url];
        fetcher.running = true;
    }

    Component.onCompleted: {
        if (root.enabled && root.gpsActive) {
            console.info("[WeatherService] Starting GPS service.");
            positionSource.start();
        }
    }

    // Geocoding process
    Process {
        id: geocoder
        command: ["curl", "-s", "--max-time", "10", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                try {
                    const data = JSON.parse(text);
                    const result = data?.results?.[0];
                    if (result) {
                        root.location = {
                            valid: true,
                            lat: result.latitude,
                            lon: result.longitude,
                            name: result.name + (result.admin1 ? `, ${result.admin1}` : "")
                        };
                        console.info(`[WeatherService] Geocoded: ${root.location.name} (${root.location.lat}, ${root.location.lon})`);
                        root.getData();
                    } else {
                        console.warn("[WeatherService] City not found, falling back to IP location");
                        root._fetchByIP();
                    }
                } catch (e) {
                    console.error(`[WeatherService] Geocoding error: ${e.message}`);
                }
            }
        }
    }

    // IP-based location fallback
    Process {
        id: ipLocator
        command: ["curl", "-s", "--max-time", "10", "http://ip-api.com/json/?fields=lat,lon,city,regionName"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                try {
                    const data = JSON.parse(text);
                    if (data.lat && data.lon) {
                        root.location = {
                            valid: true,
                            lat: data.lat,
                            lon: data.lon,
                            name: data.city + (data.regionName ? `, ${data.regionName}` : "")
                        };
                        console.info(`[WeatherService] IP location: ${root.location.name}`);
                        root.getData();
                    }
                } catch (e) {
                    console.error(`[WeatherService] IP location error: ${e.message}`);
                }
            }
        }
    }

    // Weather data fetcher
    Process {
        id: fetcher
        command: ["curl", "-s", "--max-time", "10", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                try {
                    const data = JSON.parse(text);
                    root._refineData(data);
                } catch (e) {
                    console.error(`[WeatherService] Weather fetch error: ${e.message}`);
                }
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: root.fetchInterval

        onPositionChanged: {
            if (position.latitudeValid && position.longitudeValid) {
                root.location = {
                    valid: true,
                    lat: position.coordinate.latitude,
                    lon: position.coordinate.longitude,
                    name: root.city || "GPS Location"
                };
                root.getData();
            } else {
                root.gpsActive = root.location.valid;
                console.error("[WeatherService] Failed to get GPS location.");
            }
        }

        onValidityChanged: {
            if (!positionSource.valid) {
                positionSource.stop();
                root.location.valid = false;
                root.gpsActive = false;
                Quickshell.execDetached(["notify-send", Translation.tr("Weather Service"),
                    Translation.tr("Cannot find a GPS service. Using the fallback method instead."), "-a", "Shell"]);
                console.error("[WeatherService] Could not acquire a valid backend plugin.");
                root._geocodeCity();
            }
        }
    }

    Timer {
        running: root.enabled
        repeat: true
        interval: root.fetchInterval > 0 ? root.fetchInterval : 600000
        triggeredOnStart: true
        onTriggered: root.getData()
    }
}
