// Fórmula de Haversine para calcular distância entre duas coordenadas em metros
exports.calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3; // Raio da terra em metros
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
        Math.cos(φ1) * Math.cos(φ2) *
        Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distância em metros
};

// Se o usuário estiver a mais de 50 metros do local real, é fraude (Fake GPS ou foto do zap)
exports.isLocationValid = (userLat, userLon, enigmaLat, enigmaLon, maxDistanceMeters = 50) => {
    const distance = this.calculateDistance(userLat, userLon, enigmaLat, enigmaLon);
    return distance <= maxDistanceMeters;
};