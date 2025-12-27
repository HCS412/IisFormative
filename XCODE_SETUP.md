# Xcode Project Setup Guide

## Step-by-Step: Create Fresh Xcode Project

### 1. Open Xcode
- Launch Xcode from Applications or Spotlight

### 2. Create New Project
- **File → New → Project** (or ⌘⇧N)
- Select **iOS** tab at the top
- Choose **App** template
- Click **Next**

### 3. Configure Project
Fill in the details:
- **Product Name:** `FormativeiOS`
- **Team:** Select your Apple Developer team (or "None" for now)
- **Organization Identifier:** `com.yourname` (e.g., `com.brandonbrooks`)
- **Bundle Identifier:** Will auto-fill as `com.yourname.FormativeiOS`
- **Interface:** Select **SwiftUI**
- **Language:** Select **Swift**
- **Storage:** Select **None** (we use Keychain for tokens)
- **Include Tests:** ✅ Check both (Unit Tests and UI Tests)

Click **Next**

### 4. Choose Save Location
- **Save to:** Choose a NEW location (e.g., `~/Desktop/FormativeiOS-Xcode`)
- **IMPORTANT:** Do NOT save in the same folder as the cloned repo
- Uncheck "Create Git repository" (we already have one)
- Click **Create**

### 5. Replace Default Files
The project will create default `ContentView.swift` and `FormativeiOSApp.swift`. We need to replace them:

1. **Delete default files:**
   - In Xcode, right-click `ContentView.swift` → Delete → Move to Trash
   - Right-click `FormativeiOSApp.swift` → Delete → Move to Trash

2. **Add our files:**
   - Right-click on the `FormativeiOS` folder (blue icon) in Project Navigator
   - Select **"Add Files to FormativeiOS..."**
   - Navigate to: `~/Desktop/IisFormative/`
   - Select these files:
     - `FormativeiOSApp.swift`
     - `ContentView.swift`
   - Options:
     - ✅ **Copy items if needed** (checked)
     - ✅ **Add to targets:** FormativeiOS (checked)
   - Click **Add**

### 6. Add All Source Folders
Now add all the source code folders:

1. **Right-click** on the `FormativeiOS` folder (blue icon) in Project Navigator
2. Select **"Add Files to FormativeiOS..."**
3. Navigate to: `~/Desktop/IisFormative/`
4. Select these **folders** (hold ⌘ to select multiple):
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Components/`
   - `DesignSystem/`
   - `Services/`
   - `Utilities/`
5. **IMPORTANT Options:**
   - ✅ **Copy items if needed** (checked)
   - ✅ **Create groups** (selected - NOT "Create folder references")
   - ✅ **Add to targets:** FormativeiOS (checked)
6. Click **Add**

### 7. Add Assets
Add the Assets catalog:

1. **Right-click** on the `FormativeiOS` folder
2. Select **"Add Files to FormativeiOS..."**
3. Navigate to: `~/Desktop/IisFormative/`
4. Select `Assets.xcassets/`
5. Options:
   - ✅ **Copy items if needed** (checked)
   - ✅ **Add to targets:** FormativeiOS (checked)
6. Click **Add**

### 8. Verify Project Structure
Your Project Navigator should look like:
```
FormativeiOS
├── FormativeiOSApp.swift
├── ContentView.swift
├── Models/
│   ├── User.swift
│   ├── Opportunity.swift
│   └── ...
├── ViewModels/
├── Views/
├── Components/
├── DesignSystem/
├── Services/
├── Utilities/
└── Assets.xcassets/
```

### 9. Build Settings Check
1. Click on the **FormativeiOS** project (blue icon) in Navigator
2. Select the **FormativeiOS** target
3. Go to **General** tab
4. Verify:
   - **Deployment Target:** iOS 17.0 or higher
   - **Supported Platforms:** iOS

### 10. Clean and Build
1. **Clean Build Folder:** Product → Clean Build Folder (⌘⇧K)
2. **Build:** Product → Build (⌘B)
3. Fix any import errors if they appear

### 11. Run the App
1. Select a simulator (e.g., iPhone 15 Pro)
2. **Run:** Product → Run (⌘R)

## Troubleshooting

### "Cannot find type in scope" errors
- Make sure all files are added to the target
- Check that files are in "Create groups" not "Create folder references"

### Missing imports
- Clean Build Folder (⌘⇧K)
- Quit and reopen Xcode
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`

### Files not showing in Navigator
- Make sure you selected "Create groups" not "Create folder references"
- Right-click project → Add Files to add missing files

## Success!
Once it builds successfully, you're ready to develop! 🎉

