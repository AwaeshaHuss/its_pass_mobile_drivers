#!/bin/bash

# API Testing Script for Driver Mobile API - Pass Dashboard
# Base URL
BASE_URL="https://pass.elite-center-ld.com"
AUTH_TOKEN=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✓ SUCCESS:${NC} $message" ;;
        "ERROR") echo -e "${RED}✗ ERROR:${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ INFO:${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠ WARNING:${NC} $message" ;;
    esac
}

# Function to test API endpoint
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    local description=$5
    
    echo -e "\n${BLUE}Testing: $description${NC}"
    echo "URL: $method $url"
    
    if [ -n "$data" ]; then
        echo "Data: $data"
    fi
    
    local response
    local http_code
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" $headers "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" $headers -d "$data" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "HTTP Code: $http_code"
    echo "Response: $body"
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_status "SUCCESS" "$description"
    elif [ "$http_code" -ge 400 ] && [ "$http_code" -lt 500 ]; then
        print_status "ERROR" "$description - Client Error ($http_code)"
    elif [ "$http_code" -ge 500 ]; then
        print_status "ERROR" "$description - Server Error ($http_code)"
    else
        print_status "WARNING" "$description - Unexpected response ($http_code)"
    fi
    
    echo "----------------------------------------"
}

echo "=== Driver Mobile API Testing ==="
echo "Base URL: $BASE_URL"
echo "Starting comprehensive API testing..."

# 1. UTILITY ENDPOINTS (Test first to check if server is running)
echo -e "\n${YELLOW}=== UTILITY ENDPOINTS ===${NC}"

test_endpoint "GET" "$BASE_URL/mobile/health" "" "-H 'Accept: application/json'" "Health Check"

test_endpoint "GET" "$BASE_URL/mobile/config" "" "-H 'Accept: application/json'" "App Configuration"

# 2. AUTHENTICATION ENDPOINTS
echo -e "\n${YELLOW}=== AUTHENTICATION ENDPOINTS ===${NC}"

# Driver Login
test_endpoint "POST" "$BASE_URL/mobile/driver/login" \
    '{"phone_number": "962791111111", "password": "12345678", "device_token": "fcm_token_here"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Driver Login"

# Driver Forgot Password
test_endpoint "POST" "$BASE_URL/mobile/driver/forgot-password" \
    '{"phone_number": "962791111111"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Driver Forgot Password"

# Driver Reset Password
test_endpoint "POST" "$BASE_URL/mobile/driver/reset-password" \
    '{"phone_number": "962791111111", "token": "reset_token_here", "password": "newpassword123", "password_confirmation": "newpassword123"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Driver Reset Password"

# 3. DRIVER REGISTRATION ENDPOINTS
echo -e "\n${YELLOW}=== DRIVER REGISTRATION ENDPOINTS ===${NC}"

# Check Registration Status
test_endpoint "POST" "$BASE_URL/mobile/driver/check-status" \
    '{"phone_number": "962791111111"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Check Registration Status"

# Register Driver
test_endpoint "POST" "$BASE_URL/mobile/driver/register" \
    '{"name": "Ahmed Ali", "email": "ahmed.driver@example.com", "phone_number": "962791111111", "password": "12345678", "password_confirmation": "12345678", "vehicle_type": "standard", "car_name": "Toyota", "car_model": "Camry 2020", "car_number": "123-456-789", "car_color": "White", "device_token": "fcm_token_here"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Register Driver"

# File Upload Endpoints (will fail without actual files, but we can test the endpoints)
test_endpoint "POST" "$BASE_URL/mobile/driver/upload-profile-photo" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload Profile Photo (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-id-front" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload ID Front (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-id-back" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload ID Back (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-license-front" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload License Front (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-license-back" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload License Back (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-no-conviction-certificate" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload No Conviction Certificate (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-selfie-with-id" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload Selfie with ID (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-car-image" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload Car Image (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-car-registration-front" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload Car Registration Front (No File)"

test_endpoint "POST" "$BASE_URL/mobile/driver/upload-car-registration-back" \
    "" \
    "-H 'Accept: application/json'" \
    "Upload Car Registration Back (No File)"

# 4. PROFILE & STATUS ENDPOINTS (These require authentication)
echo -e "\n${YELLOW}=== PROFILE & STATUS ENDPOINTS (Without Auth) ===${NC}"

test_endpoint "GET" "$BASE_URL/mobile/driver/profile" "" \
    "-H 'Accept: application/json'" \
    "Get Profile (No Auth)"

test_endpoint "POST" "$BASE_URL/mobile/driver/profile" \
    '{"name": "Ahmed Ali Updated", "email": "ahmed.updated@example.com", "car_name": "Toyota", "car_model": "Camry 2021", "car_color": "Black"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Update Profile (No Auth)"

test_endpoint "PUT" "$BASE_URL/mobile/driver/status" \
    '{"status": "online"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Update Status (No Auth)"

test_endpoint "PUT" "$BASE_URL/mobile/driver/location" \
    '{"latitude": 31.9539, "longitude": 35.9106, "address": "Downtown Amman, Jordan"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Update Location (No Auth)"

test_endpoint "POST" "$BASE_URL/mobile/driver/change-password" \
    '{"current_password": "12345678", "new_password": "newpassword123", "new_password_confirmation": "newpassword123"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Change Password (No Auth)"

# 5. TRIP MANAGEMENT ENDPOINTS
echo -e "\n${YELLOW}=== TRIP MANAGEMENT ENDPOINTS (Without Auth) ===${NC}"

test_endpoint "GET" "$BASE_URL/mobile/driver/available-trips?radius=10" "" \
    "-H 'Accept: application/json'" \
    "Get Available Trips (No Auth)"

test_endpoint "POST" "$BASE_URL/mobile/driver/accept-trip" \
    '{"trip_id": 1, "estimated_arrival_time": 5}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Accept Trip (No Auth)"

test_endpoint "POST" "$BASE_URL/mobile/driver/complete-trip" \
    '{"trip_id": 1, "final_amount": 15.50, "payment_method": "cash"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Complete Trip (No Auth)"

test_endpoint "PUT" "$BASE_URL/mobile/driver/trip-status" \
    '{"trip_id": 1, "status": "in_progress"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Update Trip Status (No Auth)"

test_endpoint "POST" "$BASE_URL/mobile/driver/rate-customer" \
    '{"trip_id": 1, "rating": 5, "comment": "Great customer, very polite"}' \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Rate Customer (No Auth)"

test_endpoint "GET" "$BASE_URL/mobile/driver/trip-history?page=1&per_page=20" "" \
    "-H 'Accept: application/json'" \
    "Trip History (No Auth)"

# 6. WALLET & EARNINGS ENDPOINTS
echo -e "\n${YELLOW}=== WALLET & EARNINGS ENDPOINTS (Without Auth) ===${NC}"

test_endpoint "GET" "$BASE_URL/mobile/driver/wallet" "" \
    "-H 'Accept: application/json'" \
    "Get Wallet (No Auth)"

test_endpoint "GET" "$BASE_URL/mobile/driver/earnings?period=week" "" \
    "-H 'Accept: application/json'" \
    "Get Earnings (No Auth)"

test_endpoint "GET" "$BASE_URL/mobile/driver/balance" "" \
    "-H 'Accept: application/json'" \
    "Check Balance (No Auth)"

# 7. USER INFO ENDPOINT
echo -e "\n${YELLOW}=== USER INFO ENDPOINT (Without Auth) ===${NC}"

test_endpoint "GET" "$BASE_URL/mobile/user" "" \
    "-H 'Accept: application/json'" \
    "Get User Info (No Auth)"

# 8. LOGOUT ENDPOINT
echo -e "\n${YELLOW}=== LOGOUT ENDPOINT (Without Auth) ===${NC}"

test_endpoint "POST" "$BASE_URL/mobile/driver/logout" "" \
    "-H 'Content-Type: application/json' -H 'Accept: application/json'" \
    "Driver Logout (No Auth)"

echo -e "\n${GREEN}=== API Testing Complete ===${NC}"
echo "Note: Many endpoints will return 401 Unauthorized without proper authentication token."
echo "File upload endpoints will return validation errors without actual files."
echo "This test provides a comprehensive overview of API endpoint availability and basic response structure."
