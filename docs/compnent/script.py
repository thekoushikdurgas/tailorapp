import json
import csv

# Create a comprehensive list of all screens with their details
screens_data = [
    {
        "screen_name": "Splash Screen",
        "category": "Authentication",
        "description": "App launch screen with branding",
        "components": ["App Logo", "Loading Animation", "Brand Colors"],
        "integrations": ["Firebase", "SharedPreferences"],
        "functions": ["initializeApp()", "checkAuthState()", "loadUserData()"],
        "assets": ["app_logo.png", "loading_animation.json"],
        "navigation_from": "App Launch",
        "navigation_to": "Onboarding/Login/Home"
    },
    {
        "screen_name": "Onboarding Screen",
        "category": "Authentication",
        "description": "Welcome tutorial screens",
        "components": ["PageView", "Dots Indicator", "Skip Button", "Next Button"],
        "integrations": ["SharedPreferences"],
        "functions": ["markOnboardingComplete()", "navigateToLogin()"],
        "assets": ["onboarding_1.png", "onboarding_2.png", "onboarding_3.png"],
        "navigation_from": "Splash Screen",
        "navigation_to": "Login Screen"
    },
    {
        "screen_name": "Login Screen",
        "category": "Authentication",
        "description": "User authentication entry point",
        "components": ["Email TextField", "Password TextField", "Login Button", "Google Sign In", "Forgot Password Link"],
        "integrations": ["Firebase Auth", "Google Sign In", "Biometric Auth"],
        "functions": ["signInWithEmail()", "signInWithGoogle()", "signInWithBiometric()"],
        "assets": ["google_icon.png", "fingerprint_icon.png"],
        "navigation_from": "Onboarding Screen",
        "navigation_to": "Home Screen/Registration Screen"
    },
    {
        "screen_name": "Registration Screen",
        "category": "Authentication",
        "description": "New user account creation",
        "components": ["Name TextField", "Email TextField", "Password TextField", "Confirm Password", "Terms Checkbox", "Register Button"],
        "integrations": ["Firebase Auth", "Cloud Firestore"],
        "functions": ["createUserWithEmail()", "sendEmailVerification()", "saveUserProfile()"],
        "assets": ["default_avatar.png"],
        "navigation_from": "Login Screen",
        "navigation_to": "Email Verification Screen"
    },
    {
        "screen_name": "Email Verification Screen",
        "category": "Authentication",
        "description": "Email verification confirmation",
        "components": ["Email Icon", "Verification Message", "Resend Button", "Open Email App Button"],
        "integrations": ["Firebase Auth", "Email Intent"],
        "functions": ["checkEmailVerification()", "resendVerificationEmail()"],
        "assets": ["email_verification.png"],
        "navigation_from": "Registration Screen",
        "navigation_to": "Profile Setup Screen"
    },
    {
        "screen_name": "Profile Setup Screen",
        "category": "Authentication",
        "description": "Initial user profile configuration",
        "components": ["Avatar Upload", "Name Input", "Phone Input", "Address Input", "Style Preferences"],
        "integrations": ["Cloud Firestore", "Firebase Storage", "Image Picker"],
        "functions": ["uploadProfileImage()", "saveUserProfile()", "setStylePreferences()"],
        "assets": ["camera_icon.png", "gallery_icon.png"],
        "navigation_from": "Email Verification Screen",
        "navigation_to": "Home Screen"
    },
    {
        "screen_name": "Home Screen",
        "category": "Main",
        "description": "Main dashboard with navigation",
        "components": ["AppBar", "Bottom Navigation", "Recent Designs", "Quick Actions", "AI Suggestions"],
        "integrations": ["Firebase Analytics", "Cloud Firestore", "AI Services"],
        "functions": ["loadRecentDesigns()", "getAISuggestions()", "navigateToDesignStudio()"],
        "assets": ["home_banner.png", "quick_action_icons.png"],
        "navigation_from": "Multiple Screens",
        "navigation_to": "Design Studio/Virtual Fitting/Orders/Profile"
    },
    {
        "screen_name": "Design Studio Screen",
        "category": "Design",
        "description": "Interactive garment design interface",
        "components": ["Custom Canvas", "Tool Palette", "Color Picker", "Pattern Library", "AI Assistant"],
        "integrations": ["CustomPainter", "AI Design API", "Cloud Storage"],
        "functions": ["initializeCanvas()", "drawDesignElement()", "saveDesign()", "getAIDesignSuggestions()"],
        "assets": ["design_tools.png", "pattern_library/", "color_swatches.json"],
        "navigation_from": "Home Screen",
        "navigation_to": "Virtual Fitting Screen/Save Design Dialog"
    },
    {
        "screen_name": "AI Design Assistant Screen",
        "category": "AI",
        "description": "AI-powered design suggestions",
        "components": ["Chat Interface", "Design Prompt Input", "Generated Designs Grid", "Apply Button"],
        "integrations": ["AI Generation API", "Cloud Firestore"],
        "functions": ["generateDesignFromPrompt()", "refineDesign()", "applyDesignToCanvas()"],
        "assets": ["ai_avatar.png", "design_templates/"],
        "navigation_from": "Design Studio Screen",
        "navigation_to": "Design Studio Screen"
    },
    {
        "screen_name": "Virtual Fitting Screen",
        "category": "AR/VR",
        "description": "Virtual try-on experience",
        "components": ["Camera View", "AR Overlay", "Design Preview", "Fit Adjustments", "Capture Button"],
        "integrations": ["AR Core/ARKit", "Camera Plugin", "ML Kit"],
        "functions": ["initializeARSession()", "overlayDesign()", "capturePhoto()", "analyzeFit()"],
        "assets": ["ar_models/", "fit_adjustment_icons.png"],
        "navigation_from": "Design Studio Screen",
        "navigation_to": "Measurement Input Screen/Order Summary"
    },
    {
        "screen_name": "Body Measurement Screen",
        "category": "Measurement",
        "description": "Body measurement input and capture",
        "components": ["Measurement Form", "Camera Capture", "Manual Input", "AI Analysis", "Save Button"],
        "integrations": ["Camera Plugin", "ML Kit", "Cloud Firestore"],
        "functions": ["captureBodyMeasurement()", "analyzeMeasurement()", "saveMeasurements()"],
        "assets": ["measurement_guide.png", "body_outline.svg"],
        "navigation_from": "Virtual Fitting Screen",
        "navigation_to": "Size Recommendation Screen"
    },
    {
        "screen_name": "Size Recommendation Screen",
        "category": "Measurement",
        "description": "AI-powered size recommendations",
        "components": ["Size Chart", "Recommendations List", "Fit Confidence", "Adjustment Options"],
        "integrations": ["AI Sizing API", "Cloud Firestore"],
        "functions": ["calculateSizeRecommendation()", "generateFitReport()"],
        "assets": ["size_chart.png", "fit_indicators.png"],
        "navigation_from": "Body Measurement Screen",
        "navigation_to": "Order Summary Screen"
    },
    {
        "screen_name": "Order Summary Screen",
        "category": "Orders",
        "description": "Order review and confirmation",
        "components": ["Design Preview", "Measurements Summary", "Price Breakdown", "Delivery Options", "Order Button"],
        "integrations": ["Cloud Firestore", "Payment Gateway"],
        "functions": ["calculateOrderTotal()", "validateOrder()", "proceedToPayment()"],
        "assets": ["order_summary_template.png"],
        "navigation_from": "Size Recommendation Screen",
        "navigation_to": "Payment Screen"
    },
    {
        "screen_name": "Payment Screen",
        "category": "Payment",
        "description": "Secure payment processing",
        "components": ["Payment Methods", "Card Input", "Billing Address", "Security Elements", "Pay Button"],
        "integrations": ["Stripe/Razorpay", "Firebase Functions"],
        "functions": ["processPayment()", "validatePaymentInfo()", "createPaymentIntent()"],
        "assets": ["payment_icons.png", "security_badges.png"],
        "navigation_from": "Order Summary Screen",
        "navigation_to": "Order Confirmation Screen"
    },
    {
        "screen_name": "Order Confirmation Screen",
        "category": "Orders",
        "description": "Payment confirmation and next steps",
        "components": ["Success Animation", "Order Details", "Tracking Info", "Next Steps", "Home Button"],
        "integrations": ["Firebase Analytics", "Push Notifications"],
        "functions": ["sendOrderConfirmation()", "scheduleNotifications()"],
        "assets": ["success_animation.json", "order_confirmed.png"],
        "navigation_from": "Payment Screen",
        "navigation_to": "Home Screen/Order Tracking"
    },
    {
        "screen_name": "Order Tracking Screen",
        "category": "Orders",
        "description": "Real-time order status tracking",
        "components": ["Progress Timeline", "Status Updates", "Delivery Map", "Contact Support", "Reorder Button"],
        "integrations": ["Cloud Firestore", "Maps API", "Push Notifications"],
        "functions": ["trackOrderStatus()", "updateDeliveryLocation()"],
        "assets": ["tracking_icons.png", "delivery_truck.png"],
        "navigation_from": "Order Confirmation Screen",
        "navigation_to": "Support Screen"
    },
    {
        "screen_name": "Orders History Screen",
        "category": "Orders",
        "description": "Past orders management",
        "components": ["Orders List", "Search Bar", "Filter Options", "Order Cards", "Reorder Button"],
        "integrations": ["Cloud Firestore", "Search API"],
        "functions": ["loadOrderHistory()", "searchOrders()", "filterOrders()"],
        "assets": ["order_history_icons.png"],
        "navigation_from": "Profile Screen",
        "navigation_to": "Order Details Screen"
    },
    {
        "screen_name": "Profile Screen",
        "category": "Profile",
        "description": "User profile management",
        "components": ["Profile Header", "Settings Menu", "My Designs", "Orders", "Preferences"],
        "integrations": ["Cloud Firestore", "Firebase Storage"],
        "functions": ["loadUserProfile()", "updateProfile()", "uploadAvatar()"],
        "assets": ["profile_placeholder.png", "settings_icons.png"],
        "navigation_from": "Home Screen",
        "navigation_to": "Settings/Orders/My Designs"
    },
    {
        "screen_name": "Settings Screen",
        "category": "Settings",
        "description": "App and account settings",
        "components": ["Settings Groups", "Toggle Switches", "Selection Lists", "Action Buttons"],
        "integrations": ["SharedPreferences", "Firebase Auth"],
        "functions": ["updateSettings()", "toggleNotifications()", "changeLanguage()"],
        "assets": ["settings_icons.png"],
        "navigation_from": "Profile Screen",
        "navigation_to": "Various Setting Screens"
    },
    {
        "screen_name": "My Designs Screen",
        "category": "Design",
        "description": "Saved designs gallery",
        "components": ["Designs Grid", "Search Bar", "Filter Options", "Design Cards", "Edit Button"],
        "integrations": ["Cloud Firestore", "Firebase Storage"],
        "functions": ["loadUserDesigns()", "searchDesigns()", "editDesign()"],
        "assets": ["design_thumbnails/", "grid_layout.png"],
        "navigation_from": "Profile Screen",
        "navigation_to": "Design Studio Screen"
    },
    {
        "screen_name": "Support Screen",
        "category": "Support",
        "description": "Customer support and help",
        "components": ["FAQ Section", "Contact Form", "Chat Support", "Help Articles"],
        "integrations": ["Chat API", "Email Service"],
        "functions": ["initiateChatSupport()", "sendSupportEmail()"],
        "assets": ["support_icons.png", "faq_data.json"],
        "navigation_from": "Various Screens",
        "navigation_to": "Chat Support Screen"
    }
]

# Save to CSV for easy viewing
with open('tailoring_app_screens.csv', 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ['screen_name', 'category', 'description', 'components', 'integrations', 'functions', 'assets', 'navigation_from', 'navigation_to']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    
    writer.writeheader()
    for screen in screens_data:
        # Convert lists to strings for CSV
        screen_copy = screen.copy()
        for key, value in screen_copy.items():
            if isinstance(value, list):
                screen_copy[key] = ', '.join(value)
        writer.writerow(screen_copy)

print("Created comprehensive screens data with", len(screens_data), "screens")
print("\nScreen Categories:")
categories = {}
for screen in screens_data:
    category = screen['category']
    if category not in categories:
        categories[category] = []
    categories[category].append(screen['screen_name'])

for category, screens in categories.items():
    print(f"- {category}: {len(screens)} screens")