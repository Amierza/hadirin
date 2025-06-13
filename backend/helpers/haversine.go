package helpers

import "math"

func CalculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const EarthRadius = 6371000

	dLat := (lat2 - lat1) * math.Pi / 180
	dLon := (lon2 - lon1) * math.Pi / 180

	lat1 = lat1 * math.Pi / 180
	lat2 = lat2 * math.Pi / 180

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Sin(dLon/2)*math.Sin(dLon/2)*math.Cos(lat1)*math.Cos(lat2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return EarthRadius * c
}
