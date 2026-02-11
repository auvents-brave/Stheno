#if os(Darwin)
    import Foundation
    import SwiftDate

    enum DateTimeType: String {
        case utc = " UT"
        case local = " LT"
        case relative = ""
    }

    struct DateTime {
        let date: Date
        let type: DateTimeType

        init(date: Date, type: DateTimeType) {
            self.date = date
            self.type = type
        }

        // Initialisation depuis une chaîne ISO8601 (gère les fractions avec "," ou "." et les indicateurs de fuseau horaire)
        init?(iso8601String: String) {
            // Normaliser la virgule en point pour les fractions de seconde
            let normalized = iso8601String.replacingOccurrences(of: ",", with: ".")

            // 1) Essai avec ISO8601DateFormatter (avec fractions)
            let isoWithFraction = ISO8601DateFormatter()
            isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            // Utiliser UTC comme valeur par défaut si la chaîne n'indique pas de fuseau
            isoWithFraction.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = isoWithFraction.date(from: normalized) {
                self.date = date
                type = .utc
                return
            }

            // 2) Essai avec ISO8601DateFormatter (sans fractions)
            let isoNoFraction = ISO8601DateFormatter()
            isoNoFraction.formatOptions = [.withInternetDateTime]
            isoNoFraction.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = isoNoFraction.date(from: normalized) {
                self.date = date
                type = .utc
                return
            }

            // 3) Repli avec DateFormatter pour prendre en charge jusqu'à 9 chiffres de fraction
            let posix = Locale(identifier: "en_US_POSIX")
            let df = DateFormatter()
            df.locale = posix
            df.timeZone = TimeZone(secondsFromGMT: 0)
            let patterns = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSXXXXX", // jusqu'à 9 chiffres
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // 6 chiffres
                "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", // 3 chiffres
                "yyyy-MM-dd'T'HH:mm:ssXXXXX", // sans fractions
            ]
            for pattern in patterns {
                df.dateFormat = pattern
                if let date = df.date(from: normalized) {
                    self.date = date
                    type = .utc
                    return
                }
            }

            return nil
        }

        /// Alternate initializer that parses ISO8601 using SwiftDate
        /// - Parameter iso8601String: An ISO8601 date string (supports fractions and time zones as handled by SwiftDate)
        /// - Note: Requires the SwiftDate dependency to be available for this target.
        init?(iso8601String: String, usingSwiftDate: Bool) {
            guard usingSwiftDate else { return nil }

            // Normalize comma to dot for fractional seconds to mirror the Foundation-based initializer
            let normalized = iso8601String.replacingOccurrences(of: ",", with: ".")

            // Define a UTC region to align with your current behavior (treat parsed date as absolute UTC)
            let utcRegion = Region(calendar: Calendars.gregorian, zone: Zones.gmt, locale: Locales.english)

            // 1) Try SwiftDate's natural-language parser in the given region.
            if let dr = DateInRegion(normalized, region: utcRegion) {
                date = dr.date
                type = .utc
                return
            }

            // 2) Try a few explicit ISO8601-like patterns commonly encountered.
            //    Add or adjust patterns as needed for your inputs.
            let explicitPatterns: [String] = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", // fractional seconds + TZ offset
                "yyyy-MM-dd'T'HH:mm:ssXXXXX", // no fractional, TZ offset
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // fractional seconds + Z
                "yyyy-MM-dd'T'HH:mm:ss'Z'", // no fractional, Z
                "yyyy-MM-dd", // date only
            ]

            for pattern in explicitPatterns {
                if let dr = DateInRegion(normalized, format: pattern, region: utcRegion) {
                    date = dr.date
                    type = .utc
                    return
                }
            }

            return nil
        }

        func converted(to targetType: DateTimeType) -> Date {
            return date
        }

        func formatted(in targetType: DateTimeType, format: String = "yyyy-MM-dd HH:mm:ss") -> (value: String, unit: String) {
            switch targetType {
            case .relative:
                #if canImport(Darwin)
                    // RelativeDateTimeFormatter is available on Apple platforms via Foundation
                    if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                        let rel = RelativeDateTimeFormatter()
                        rel.unitsStyle = .full
                        let value = rel.localizedString(for: self.date, relativeTo: Date())
                        return (value, targetType.rawValue)
                    }
                #endif
                // Fallback for platforms without RelativeDateTimeFormatter: use absolute formatting in local time
                let fallback = DateFormatter()
                fallback.dateFormat = format
                fallback.timeZone = TimeZone.current
                return (fallback.string(from: date), targetType.rawValue)

            case .utc, .local:
                let formatter = DateFormatter()
                formatter.dateFormat = format
                switch targetType {
                case .utc:
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                case .local:
                    formatter.timeZone = TimeZone.current
                default:
                    break
                }
                return (formatter.string(from: date), targetType.rawValue)
            }
        }

        /// General formatting using SwiftDate (6.3.x compatible)
        /// - Parameters:
        ///   - targetType: `.utc` uses GMT, `.local`/`.relative` use the current region
        ///   - format: a custom date pattern understood by SwiftDate's `.custom` formatter
        /// - Returns: tuple of the formatted string and the unit tag
        func formattedWithSwiftDate(in targetType: DateTimeType, format: String = "yyyy-MM-dd HH:mm:ss") -> (value: String, unit: String) {
            // Define UTC and pick local region dynamically
            let utcRegion = Region(calendar: Calendars.gregorian, zone: Zones.gmt, locale: Locales.english)
            let region: Region = (targetType == .utc) ? utcRegion : Region.current

            // Wrap the stored Date in the chosen region and format using a custom pattern
            let dr = DateInRegion(date, region: region)
            let string = dr.toString(.custom(format))
            return (string, targetType.rawValue)
        }

        // Formatage en ISO8601
        func formattedISO(in targetType: DateTimeType) -> (value: String, unit: String) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            switch targetType {
            case .utc:
                formatter.timeZone = TimeZone(abbreviation: "UTC")
            case .local, .relative:
                formatter.timeZone = TimeZone.current
            }

            return (formatter.string(from: date), targetType.rawValue)
        }

        /// ISO8601 formatting using SwiftDate (6.3.x compatible)
        /// - Parameters:
        ///   - targetType: `.utc` uses GMT, `.local`/`.relative` use the current time zone
        ///   - includeFractionalSeconds: when true, emits milliseconds (3 digits). Adjust pattern if you need more precision.
        /// - Returns: tuple of the formatted string and the unit tag
        func formattedISOWithSwiftDate(in targetType: DateTimeType, includeFractionalSeconds: Bool = true) -> (value: String, unit: String) {
            // Define a stable UTC region
            let utcRegion = Region(calendar: Calendars.gregorian, zone: Zones.gmt, locale: Locales.english)
            // Build an ISO8601 pattern; use 3 fractional digits by default
            let pattern = includeFractionalSeconds ? "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" : "yyyy-MM-dd'T'HH:mm:ssXXXXX"

            switch targetType {
            case .utc:
                let dr = DateInRegion(date, region: utcRegion)
                let string = dr.toString(.custom(pattern))
                return (string, targetType.rawValue)

            case .local, .relative:
                // Prefer Region.current for local formatting in SwiftDate 6.3.x
                let localRegion = Region.current
                let dr = DateInRegion(date, region: localRegion)
                let string = dr.toString(.custom(pattern))
                return (string, targetType.rawValue)
            }
        }
    }

    // MARK: - Examples (Playground)

    #if canImport(Playgrounds)
        import Playgrounds

        #Playground {
            // Distance courte (< 300m)
            let shortDistance = Distance(value: 150, unit: .meters)
            let shortDistanceType = shortDistance.type
            let shortInFeet = shortDistance.converted(to: .feet)

            // Distance longue (>= 300m)
            let longDistance = Distance(value: 5, unit: .kilometers)
            let longDistanceType = longDistance.type
            let longInMiles = longDistance.converted(to: .miles)
            let longInNM = longDistance.converted(to: .nauticalMiles)

            // Vitesse
            let speedKmh = Speed(value: 100, unit: .kilometersPerHour)
            let speedMph = speedKmh.converted(to: .milesPerHour)
            let speedKnots = Speed(value: 25, unit: .knots)
            let speedKnotsToKmh = speedKnots.converted(to: .kilometersPerHour)

            // Date/Heure - depuis Date
            let dateTime = DateTime(date: Date(), type: .utc)
            let utcFormatted = dateTime.formatted(in: .utc)
            let localFormatted = dateTime.formatted(in: .local)
            let isoUTC = dateTime.formattedISO(in: .utc)
            let isoLocal = dateTime.formattedISO(in: .local)

            // Cas d'heure locale
            // 1) Construction d'une DateTime en local et formatage local/ISO local
            let nowLocal = DateTime(date: Date(), type: .local)
            let nowLocalFormatted = nowLocal.formatted(in: .local)
            let nowLocalISO = nowLocal.formattedISO(in: .local)

            // 2) Analyse d'ISO avec décalage local et avec Z, puis formatage en local et UTC
            let localISOWithComma = "2025-02-16T12:03:17,646296349+01:00"
            let localISOWithDotZ = "2025-02-16T10:58:44.965071Z"

            let dtFromLocalOffset = DateTime(iso8601String: localISOWithComma)
            let dtFromZ = DateTime(iso8601String: localISOWithDotZ)

            let dtFromLocalOffsetLocalFmt = dtFromLocalOffset?.formatted(in: .local)
            let dtFromLocalOffsetUTC = dtFromLocalOffset?.formatted(in: .utc)

            let dtFromZLocalFmt = dtFromZ?.formatted(in: .local)
            let dtFromZUTC = dtFromZ?.formatted(in: .utc)

            // Date/Heure - format relatif
            let fiveMinutesAgo = DateTime(date: Date().addingTimeInterval(-5 * 60), type: .local)
            let relativeFormatted = fiveMinutesAgo.formatted(in: .relative)

            let A = dtFromLocalOffset!.formattedWithSwiftDate(in: .local)
            let B = dtFromLocalOffset!.formattedWithSwiftDate(in: .utc)
        }
    #endif
#endif
