# Network Connection Troubleshooting Guide

## Issue: Connection Timeout
Your Flutter app is getting connection timeout errors when trying to connect to the backend server.

## Changes Made

### 1. Increased Timeouts
- Connection timeout: 30s → 60s
- Receive timeout: 30s → 60s
- Added send timeout: 60s

### 2. Enhanced Error Handling
- Better error logging with specific timeout messages
- Network diagnostics when connection errors occur
- Connection tests to identify specific issues

### 3. Network Configuration
- Added network options for better connectivity
- Enhanced logging to show request details
- Android emulator specific optimizations

## Troubleshooting Steps

### Step 1: Verify Server is Running
```bash
# Check if server is accessible from your machine
curl http://192.168.100.79:3001/
curl http://localhost:3001/
```

### Step 2: Check Network Configuration
- Ensure your Flutter app and server are on the same network
- Check if firewall is blocking port 3001
- Verify the IP address is correct for your network

### Step 3: Test from Flutter App
The app now includes automatic diagnostics when connection errors occur. Look for these logs:
- Network diagnostics results
- Connection test results
- Detailed error information

### Step 4: Common Solutions

#### Android Emulator Issues
- Use `10.0.2.2` instead of `localhost` if testing on same machine
- Use your machine's actual IP address (not localhost)
- Check emulator network settings

#### Network Issues
- Ensure both devices are on same WiFi network
- Check router settings for device isolation
- Try disabling firewall temporarily

#### Server Issues
- Check if server is binding to all interfaces (`0.0.0.0`)
- Verify CORS settings allow your app
- Check server logs for errors

### Step 5: Manual Testing
You can manually test connections using the new utilities:

```dart
// Test basic connectivity
await ConnectionTest.testBasicConnection();

// Test specific endpoint
await ConnectionTest.testAuthEndpoint();

// Run all tests
await ConnectionTest.runAllTests();
```

## Configuration

### Current Settings
- Base URL: `http://192.168.100.79:3001/api`
- Connection Timeout: 60 seconds
- Receive Timeout: 60 seconds
- Send Timeout: 60 seconds

### To Change IP Address
Update `lib/core/app_config.dart`:
```dart
return 'http://YOUR_NEW_IP:3001/api';
```

## Next Steps
1. Try the login again - you should see detailed diagnostics
2. Check the console logs for specific error details
3. Run manual connection tests if needed
4. Adjust timeouts or IP address as needed

## Still Having Issues?
If the problem persists:
1. Check server logs for any errors
2. Verify network connectivity between devices
3. Try using a different port
4. Consider using ngrok for temporary public access
