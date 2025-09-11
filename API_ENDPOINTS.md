# API Endpoints Documentation

This document outlines the required API endpoints to replace Firebase services in the Uber Drivers App.

## Base URL
```
https://your-api-base-url.com/api
```

## Authentication Endpoints

### 1. Send OTP
**POST** `/auth/send-otp`

**Request Body:**
```json
{
  "phoneNumber": "+1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "verificationId": "unique-verification-id",
  "message": "OTP sent successfully"
}
```

### 2. Verify OTP
**POST** `/auth/verify-otp`

**Request Body:**
```json
{
  "verificationId": "unique-verification-id",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt-auth-token",
  "driver": {
    "id": "driver-uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "profileImageUrl": "https://...",
    "isBlocked": false,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z",
    "vehicle": {
      "type": "car",
      "make": "Toyota",
      "model": "Camry",
      "year": 2020,
      "licensePlate": "ABC123",
      "color": "White"
    }
  }
}
```

### 3. Google Sign-In
**POST** `/auth/google-signin`

**Request Body:**
```json
{
  "accessToken": "google-access-token",
  "idToken": "google-id-token"
}
```

**Response:** Same as verify OTP response

### 4. Sign Out
**POST** `/auth/signout`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Response:**
```json
{
  "success": true,
  "message": "Signed out successfully"
}
```

## Driver Management Endpoints

### 5. Get Driver Profile
**GET** `/drivers/{driverId}`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Response:**
```json
{
  "id": "driver-uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "profileImageUrl": "https://...",
  "isBlocked": false,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "vehicle": {
    "type": "car",
    "make": "Toyota",
    "model": "Camry",
    "year": 2020,
    "licensePlate": "ABC123",
    "color": "White"
  }
}
```

### 6. Update Driver Profile
**PUT** `/drivers/{driverId}`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "profileImageUrl": "https://...",
  "vehicle": {
    "type": "car",
    "make": "Toyota",
    "model": "Camry",
    "year": 2020,
    "licensePlate": "ABC123",
    "color": "White"
  }
}
```

**Response:** Same as get driver profile response

### 7. Check Driver Status
**GET** `/drivers/{driverId}/status`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Response:**
```json
{
  "isBlocked": false,
  "isOnline": true,
  "status": "available"
}
```

### 8. Check Profile Completeness
**GET** `/drivers/{driverId}/profile-status`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Response:**
```json
{
  "isComplete": true,
  "missingFields": []
}
```

### 9. Update Device Token
**PUT** `/drivers/{driverId}/device-token`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Request Body:**
```json
{
  "deviceToken": "firebase-device-token"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Device token updated successfully"
}
```

## Trip Management Endpoints

### 10. Get Trip Details
**GET** `/trips/{tripId}`

**Headers:**
```
Authorization: Bearer jwt-auth-token
```

**Response:**
```json
{
  "tripID": "trip-uuid",
  "pickUpLatLng": {
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "pickUpAddress": "123 Main St, San Francisco, CA",
  "dropOffLatLng": {
    "latitude": 37.7849,
    "longitude": -122.4094
  },
  "dropOffAddress": "456 Oak St, San Francisco, CA",
  "userName": "Jane Smith",
  "userPhone": "+1987654321",
  "bidAmount": "25.00",
  "fareAmount": "30.00",
  "status": "pending",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## File Upload Endpoints

### 11. Upload Profile Image
**POST** `/upload/profile-image`

**Headers:**
```
Authorization: Bearer jwt-auth-token
Content-Type: multipart/form-data
```

**Request Body:**
```
image: [file]
```

**Response:**
```json
{
  "success": true,
  "imageUrl": "https://your-cdn.com/images/profile-123.jpg"
}
```

## Error Responses

All endpoints should return appropriate HTTP status codes and error messages:

**400 Bad Request:**
```json
{
  "success": false,
  "error": "Invalid request parameters",
  "message": "Phone number is required"
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "Driver account is blocked"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": "Not found",
  "message": "Driver not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "error": "Internal server error",
  "message": "An unexpected error occurred"
}
```

## Notes

1. All timestamps should be in ISO 8601 format (UTC)
2. JWT tokens should have appropriate expiration times
3. Phone numbers should be in international format
4. File uploads should be validated for size and type
5. All endpoints should implement proper rate limiting
6. CORS should be configured for web clients
7. All sensitive data should be encrypted in transit and at rest
