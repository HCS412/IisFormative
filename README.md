# Formative iOS App

Native SwiftUI iOS application for the Formative platform.

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/HCS412/IisFormative.git
cd IisFormative
```

### 2. Create New Xcode Project

**Important:** Start with a fresh Xcode project to avoid corrupted project files.

1. Open **Xcode**
2. **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - **Product Name:** `FormativeiOS`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
   - **Storage:** `None` (we use Keychain for tokens)
5. **Save** to a new location (e.g., `~/Desktop/FormativeiOS-Fresh`)

### 3. Add Files to Xcode

1. In Xcode, **right-click** on the `FormativeiOS` folder in the project navigator
2. Select **"Add Files to FormativeiOS..."**
3. Navigate to the cloned repository folder
4. Select **ALL** folders:
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Components/`
   - `DesignSystem/`
   - `Services/`
   - `Utilities/`
   - `Assets.xcassets/`
5. **Important options:**
   - ✅ **Copy items if needed** (checked)
   - ✅ **Create groups** (selected)
   - ✅ **Add to targets:** FormativeiOS (checked)
6. Click **Add**

### 4. Replace Default Files

Replace the default `ContentView.swift` and `FormativeiOSApp.swift` with the ones from the repository.

### 5. Build and Run

1. **Clean Build Folder:** ⌘⇧K
2. **Build:** ⌘B
3. **Run:** ⌘R

## 📁 Project Structure

```
FormativeiOS/
├── FormativeiOSApp.swift       # App entry point
├── ContentView.swift           # Root view with auth routing
│
├── Models/                     # Data models
│   ├── User.swift
│   ├── Opportunity.swift
│   ├── Message.swift
│   ├── Notification.swift
│   ├── Campaign.swift
│   └── Team.swift
│
├── ViewModels/                 # MVVM view models
│   ├── AuthViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── OpportunitiesViewModel.swift
│   ├── MessagesViewModel.swift
│   ├── NotificationsViewModel.swift
│   ├── CampaignsViewModel.swift
│   └── TeamsViewModel.swift
│
├── Views/                      # UI screens
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Opportunities/
│   │   ├── OpportunitiesListView.swift
│   │   └── OpportunityDetailView.swift
│   ├── Messages/
│   │   ├── ConversationsListView.swift
│   │   └── ChatView.swift
│   ├── Notifications/
│   │   └── NotificationsView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   ├── Campaigns/
│   │   └── CampaignsListView.swift
│   └── Teams/
│       └── TeamsListView.swift
│
├── Components/                 # Reusable UI components
│   ├── Buttons/
│   │   ├── PrimaryButton.swift
│   │   ├── SecondaryButton.swift
│   │   └── FloatingActionButton.swift
│   ├── Cards/
│   │   ├── GlassCard.swift
│   │   └── StatCard.swift
│   ├── Inputs/
│   │   └── FormTextField.swift
│   ├── Loading/
│   │   └── SkeletonView.swift
│   ├── EmptyStates/
│   │   └── EmptyStateView.swift
│   └── Search/
│       └── SearchBar.swift
│
├── DesignSystem/               # Design system
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   ├── CornerRadius.swift
│   └── Gradients.swift
│
├── Services/                   # API & storage
│   ├── APIClient.swift
│   └── KeychainService.swift
│
└── Utilities/                  # Helpers
    ├── Haptics.swift
    ├── Animations.swift
    └── Extensions.swift
```

## ✨ Features

### ✅ Implemented

- **Authentication** - Login, Register, JWT token management
- **Dashboard** - Personalized greeting, stats, activity feed
- **Opportunities** - Browse, search, filter, apply
- **Messages** - Conversations and chat
- **Notifications** - Notification center with filters
- **Profile** - User profile and settings
- **Campaigns** - Campaign management
- **Teams** - Team collaboration

### 🎨 Design System

- **Glass Morphism** - Ultra-thin material with gradient borders
- **Liquid Blob Backgrounds** - Animated gradient blobs
- **Spring Animations** - Natural, bouncy interactions
- **Haptic Feedback** - Impact, notification, and selection feedback
- **Dark Mode** - Full support with adaptive colors

## 🔧 Configuration

### Backend API

Update the API base URL in `Services/APIClient.swift`:

```swift
private let baseURL = "https://your-api-url.com/api"
```

### Info.plist

Add network permissions if needed:
- The app requires network access to call the backend API

## 📱 Requirements

- **iOS:** 17.0+
- **Xcode:** 15.0+
- **Swift:** 5.9+

## 🛠️ Development

### Architecture

- **MVVM** (Model-View-ViewModel) pattern
- **SwiftUI** for UI
- **Combine** for reactive programming
- **Keychain** for secure token storage

### Testing

Run tests with:
```bash
⌘U in Xcode
```

## 📝 Notes

- All spacing uses the design system constants
- Colors adapt automatically for dark mode
- Haptic feedback is integrated into interactive elements
- Animations use spring physics for natural feel
- Glass morphism is available via `.glassStyle()` modifier

## 🐛 Troubleshooting

### Build Errors

1. **Clean Build Folder:** ⌘⇧K
2. **Delete DerivedData:** 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
3. **Quit and reopen Xcode**

### Missing Files

If files are missing from the project:
1. Right-click on the project folder
2. Select "Add Files to FormativeiOS..."
3. Navigate to the file and add it

## 📄 License

[Your License Here]

## 👥 Contributors

- [Your Name]

---

**Repository:** https://github.com/HCS412/IisFormative

