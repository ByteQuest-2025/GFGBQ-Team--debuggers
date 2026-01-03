# Screen Architecture - Micro Investment Platform
## Minimum Viable Product (MVP) Screens

---

## 📱 Total Screens: **8 Core Screens** (Minimum)

---

## 1. **SPLASH SCREEN / WELCOME SCREEN**
**Purpose**: First impression, app loading, brand introduction

### What it does:
- Shows app logo and name
- Brief loading (2-3 seconds)
- Checks if user is logged in
- Routes to Onboarding (new user) or Home (existing user)

### Key Elements:
- App logo/icon
- App name: "Micro Invest"
- Tagline: "Investing for Everyone"
- Loading indicator (minimal)
- Version number (small, bottom)

### User Flow:
```
Splash → Check Login Status
  ├─ Not Logged In → Onboarding Screen
  └─ Logged In → Home Screen
```

### Technical Notes:
- Auto-navigates after 2 seconds
- Can skip if user taps screen
- Stores first launch status

---

## 2. **ONBOARDING SCREEN** (3-4 slides)
**Purpose**: Introduce app, build trust, explain value

### What it does:
- Shows 3-4 simple slides explaining the app
- Explains: "Invest with ₹10", "Learn as you go", "Safe & Simple"
- Gets basic user info (optional)
- Creates first impression

### Slide 1: "Start Small"
- **Visual**: ₹10 coin animation
- **Text**: "Start investing with just ₹10"
- **Subtext**: "No need for large amounts"

### Slide 2: "Learn & Earn"
- **Visual**: Book + Growth chart icon
- **Text**: "Learn about investing as you go"
- **Subtext**: "Simple lessons, no jargon"

### Slide 3: "Safe & Secure"
- **Visual**: Shield/Trust icon
- **Text**: "Your money is safe with us"
- **Subtext**: "Transparent, no hidden charges"

### Slide 4: "Get Started" (Optional)
- **Visual**: Arrow/Start icon
- **Text**: "Ready to start your journey?"
- **Button**: "Get Started" or "Skip"

### Key Elements:
- Swipeable cards (one per slide)
- Page indicators (dots showing current slide)
- "Next" button (right side)
- "Skip" button (top right, optional)
- "Get Started" button (last slide)

### User Flow:
```
Onboarding → Swipe through slides
  └─ Tap "Get Started" → Registration Screen
```

### Technical Notes:
- Swipe left/right to navigate
- Skip button available on all slides
- Stores "onboarding completed" status
- Never shows again after completion

---

## 3. **REGISTRATION / LOGIN SCREEN**
**Purpose**: User authentication and account creation

### What it does:
- Creates new account or logs in existing user
- Collects minimal required info
- Phone number based (works in rural areas)
- OTP verification

### Registration Flow:
1. **Phone Number Input**
   - Country code (+91)
   - 10-digit phone number
   - "Continue" button
   - Validation: Must be 10 digits

2. **OTP Verification**
   - 6-digit OTP input
   - Auto-read SMS (if available)
   - "Resend OTP" button (after 30 seconds)
   - "Verify" button

3. **Basic Info** (Optional, can skip)
   - Name (optional)
   - Age (optional, for KYC later)
   - "Skip for now" option

### Login Flow:
1. **Phone Number Input**
   - Enter registered phone
   - "Login" button

2. **OTP Verification**
   - Same as registration

### Key Elements:
- Phone number input field
- OTP input (6 boxes or single field)
- "Continue/Verify" button
- "Resend OTP" link
- "Already have account? Login" link
- Back button

### User Flow:
```
Registration Screen
  ├─ Enter Phone → OTP Screen
  ├─ Verify OTP → Basic Info (Optional)
  └─ Complete → Home Screen

Login Screen
  ├─ Enter Phone → OTP Screen
  └─ Verify OTP → Home Screen
```

### Technical Notes:
- Phone number validation
- OTP expires in 5 minutes
- Stores user session
- Can use biometric login after first login (optional)

---

## 4. **HOME SCREEN / DASHBOARD**
**Purpose**: Main hub, shows overview, quick actions

### What it does:
- Shows user's investment summary
- Displays learning progress
- Quick access to main features
- Daily challenges/streaks
- Recent activity

### Top Section: Greeting & Balance
- "Hello, [Name]" or "Hello, Investor"
- Total invested amount: "₹XXX invested"
- Current value: "₹XXX (Growth: +X%)"
- Simple chart (optional, can be hidden)

### Middle Section: Quick Actions (Cards)
1. **"Start Learning" Card**
   - Progress: "Module 2 of 5"
   - Button: "Continue Learning"
   - Shows next lesson

2. **"Invest Now" Card**
   - "Start with ₹10"
   - Button: "Invest"
   - Shows investment options

3. **"Daily Challenge" Card**
   - Today's challenge: "Read 1 lesson"
   - Streak: "🔥 7 days"
   - Button: "Complete Challenge"

### Bottom Section: Recent Activity
- "Recent Activity"
- List: "Invested ₹50", "Completed Lesson 3", etc.
- "View All" link

### Navigation:
- Bottom navigation bar (if needed)
- Or hamburger menu (minimal)

### Key Elements:
- Greeting text
- Investment summary (amount, growth)
- Quick action cards (3-4 cards)
- Daily challenge widget
- Streak indicator
- Recent activity list
- Navigation to other screens

### User Flow:
```
Home Screen
  ├─ Tap "Start Learning" → Learning Screen
  ├─ Tap "Invest Now" → Investment Screen
  ├─ Tap "Daily Challenge" → Challenge Screen
  ├─ Tap Investment Card → Portfolio Screen
  └─ Tap Profile Icon → Profile Screen
```

### Technical Notes:
- Pull to refresh
- Auto-updates every 5 minutes (if online)
- Shows offline indicator if no internet
- Minimal data usage

---

## 5. **LEARNING / EDUCATION SCREEN**
**Purpose**: Interactive learning modules and lessons

### What it does:
- Lists all available lessons
- Shows progress for each lesson
- Interactive learning content
- Quizzes after lessons
- Badge rewards

### Screen Layout:

**Top Section:**
- "Learning" title
- Overall progress: "40% Complete"
- XP points: "1,250 XP"
- Level: "Level 2: Learner"

**Module List:**
Each module shows:
- Module number and title
- Progress: "3/5 lessons completed"
- Lock status: 🔒 (if locked) or ✅ (if completed)
- "Start" or "Continue" button

**Module Examples:**
1. **Module 1: "What is Money?"** (Unlocked)
   - 5 lessons
   - Progress: "3/5 completed"
   - Status: "In Progress"

2. **Module 2: "Saving vs Investing"** (Unlocked)
   - 5 lessons
   - Progress: "0/5 completed"
   - Status: "Not Started"

3. **Module 3: "Safe Investments"** (Locked)
   - 5 lessons
   - Status: "Complete Module 2 to unlock"

### Lesson View (When opened):
- Lesson title
- Content (text, images, simple animations)
- Progress: "Page 3 of 5"
- Navigation: Previous/Next buttons
- "Take Quiz" button (at end)
- "Mark as Complete" button

### Quiz View:
- Question 1 of 5
- Question text
- Multiple choice options (2-4 options)
- "Next" button
- Progress indicator

### Quiz Results:
- Score: "4/5 Correct!"
- XP earned: "+50 XP"
- Badge earned: "🏆 Knowledge Seeker"
- "Continue Learning" button
- "Retake Quiz" button

### Key Elements:
- Module list with progress
- Lesson content viewer
- Quiz interface
- Progress indicators
- XP and badge notifications
- Download for offline (optional)

### User Flow:
```
Learning Screen
  ├─ Tap Module → Module Detail
  ├─ Tap Lesson → Lesson View
  ├─ Complete Lesson → Quiz Screen
  ├─ Complete Quiz → Results Screen
  └─ Back → Learning Screen
```

### Technical Notes:
- Lessons downloadable for offline
- Progress saved locally
- Syncs when online
- Lightweight content (< 2MB per lesson)

---

## 6. **INVESTMENT / PORTFOLIO SCREEN**
**Purpose**: View investments, make new investments, track portfolio

### What it does:
- Shows current investments
- Allows new investments (₹10 minimum)
- Displays portfolio value
- Shows growth/returns
- Investment history

### Top Section: Portfolio Summary
- Total invested: "₹500 invested"
- Current value: "₹525"
- Total returns: "+₹25 (+5%)"
- Simple chart (line chart, optional)

### Investment Options Section:
**"Invest Now" Button**
- Opens investment options

**Investment Types:**
1. **Safe Fund** (Low risk)
   - Returns: "4-6% per year"
   - Risk: "Very Low"
   - Min: "₹10"
   - Button: "Invest"

2. **Growth Fund** (Moderate risk)
   - Returns: "6-8% per year"
   - Risk: "Low"
   - Min: "₹10"
   - Button: "Invest"

3. **Balanced Fund** (Medium risk)
   - Returns: "8-10% per year"
   - Risk: "Medium"
   - Min: "₹10"
   - Button: "Invest"

### Current Investments List:
Each investment shows:
- Fund name
- Amount invested: "₹100"
- Current value: "₹105"
- Returns: "+₹5 (+5%)"
- Duration: "Invested 30 days ago"
- "View Details" button

### Investment Flow:
1. **Select Investment Type**
   - Tap on fund card
   - See details

2. **Enter Amount**
   - Amount input: "₹10" (minimum)
   - Slider or input field
   - Shows: "You'll invest ₹10"
   - "Continue" button

3. **Confirm Investment**
   - Review: "Invest ₹10 in Safe Fund"
   - Terms checkbox: "I understand the risks"
   - "Confirm Investment" button

4. **Success**
   - "Investment successful!"
   - "You invested ₹10"
   - "View Portfolio" button

### Key Elements:
- Portfolio summary (total, returns)
- Investment options list
- Current investments list
- Investment flow (select → amount → confirm)
- Success/confirmation screens
- Investment history

### User Flow:
```
Investment Screen
  ├─ Tap "Invest Now" → Investment Options
  ├─ Select Fund → Enter Amount Screen
  ├─ Enter Amount → Confirm Screen
  ├─ Confirm → Success Screen
  └─ View Portfolio → Portfolio Details
```

### Technical Notes:
- Minimum investment: ₹10
- Real-time or delayed updates (based on connectivity)
- Offline mode: Queue investments, sync when online
- Clear risk indicators
- Simple terms (no jargon)

---

## 7. **PROFILE / SETTINGS SCREEN**
**Purpose**: User account, settings, achievements, help

### What it does:
- Shows user profile
- Displays achievements/badges
- App settings
- Help & support
- Logout

### Top Section: Profile
- User name or phone number
- Level: "Level 2: Learner"
- XP: "1,250 XP"
- Join date: "Member since Jan 2024"

### Sections:

**1. Achievements**
- Badge collection
- "You've earned 5 badges"
- Grid of badges (earned and locked)
- Tap badge to see details

**2. Investment Stats**
- Total invested: "₹500"
- Total returns: "+₹25"
- Investment count: "10 investments"
- Longest streak: "30 days"

**3. Learning Stats**
- Lessons completed: "15/25"
- Quizzes passed: "12/15"
- Current streak: "7 days"
- Total XP: "1,250 XP"

**4. Settings**
- Language (if multilingual)
- Notifications (on/off)
- Biometric login (on/off)
- Data usage (minimal/normal)
- App version

**5. Help & Support**
- FAQ
- Contact support
- Terms & conditions
- Privacy policy
- About app

**6. Account**
- Edit profile (name, etc.)
- Change phone number
- KYC status (if applicable)
- Logout

### Key Elements:
- Profile header (name, level, XP)
- Achievement badges grid
- Stats cards
- Settings list
- Help section
- Logout button

### User Flow:
```
Profile Screen
  ├─ Tap Achievement → Badge Details
  ├─ Tap Settings → Settings Screen
  ├─ Tap Help → Help Screen
  ├─ Tap Logout → Confirm → Login Screen
  └─ Back → Home Screen
```

### Technical Notes:
- All data stored locally (privacy-first)
- Minimal server calls
- Offline accessible
- Clear logout confirmation

---

## 8. **DAILY CHALLENGE / GAMIFICATION SCREEN** (Optional but Recommended)
**Purpose**: Daily engagement, streaks, gamification

### What it does:
- Shows today's challenge
- Displays streak calendar
- Shows XP and level progress
- Leaderboard (optional)

### Top Section: Today's Challenge
- Challenge card: "Read 1 lesson"
- Reward: "+20 XP"
- "Complete Challenge" button
- Status: "Not Started" / "Completed" / "Claimed"

### Streak Section:
- Current streak: "🔥 7 days"
- Visual calendar (7-day or 30-day view)
- Marked days: ✅ (completed), ❌ (missed)
- "Keep your streak alive!"

### Progress Section:
- Level progress bar: "Level 2 (1,250/2,000 XP)"
- "Next level in 750 XP"
- Visual progress bar

### Weekly Summary:
- "This week you:"
  - Completed 5 challenges
  - Earned 150 XP
  - Maintained 7-day streak

### Key Elements:
- Daily challenge card
- Streak calendar
- Level progress
- XP counter
- Weekly summary
- Achievement notifications

### User Flow:
```
Challenge Screen
  ├─ Tap Challenge → Complete Task → Claim Reward
  ├─ View Streak → Calendar View
  └─ Back → Home Screen
```

### Technical Notes:
- Updates daily at midnight
- Streak freeze feature (1 per month)
- Offline tracking (syncs when online)
- Motivational messages

---

## 📊 Complete App Flow - From Splash to All Screens

### **COMPLETE NAVIGATION FLOW**

```
┌─────────────────────────────────────────────────────────────┐
│                    APP LAUNCH                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  1. SPLASH SCREEN                                            │
│     - App logo, name, tagline                                │
│     - Loading (2-3 seconds)                                 │
│     - Checks: Is user logged in?                            │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
            ▼                               ▼
    ┌───────────────┐              ┌───────────────┐
    │  NEW USER     │              │ EXISTING USER │
    │ (Not logged)  │              │  (Logged in)  │
    └───────────────┘              └───────────────┘
            │                               │
            ▼                               │
┌───────────────────────────────────────────┴───────────────--┐
│  2. ONBOARDING SCREEN (3-4 slides)                          │
│     Slide 1: "Start Small" (₹10 coin)                       │
│     Slide 2: "Learn & Earn" (Book + Chart)                  │
│     Slide 3: "Safe & Secure" (Shield icon)                  │
│     Slide 4: "Get Started" button                           │
│     - Swipe left/right to navigate                          │
│     - "Skip" button (top right)                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  3. REGISTRATION/LOGIN SCREEN                               │
│                                                             │
│  REGISTRATION FLOW:                                         │
│  ┌─────────────────────────────────────┐                    │
│  │ Step 1: Phone Number Input           │                   │
│  │ - Enter country code (+91)           │                   │
│  │ - Enter 10-digit phone number        │                   │
│  │ - Tap "Continue"                     │                   │
│  └─────────────────────────────────────┘                    │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                    │
│  │ Step 2: OTP Verification            │                    │
│  │ - Enter 6-digit OTP                  │                   │
│  │ - Auto-read SMS (if available)       │                   │
│  │ - "Resend OTP" (after 30 sec)       │                    │
│  │ - Tap "Verify"                       │                   │
│  └─────────────────────────────────────┘                    │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                    │
│  │ Step 3: Basic Info (Optional)        │                   │
│  │ - Name (optional)                    │                   │
│  │ - Age (optional)                     │                   │
│  │ - "Skip for now" or "Continue"       │                   │
│  └─────────────────────────────────────┘                    │
│                                                             │
│  LOGIN FLOW:                                                │
│  ┌─────────────────────────────────────┐                    │
│  │ Step 1: Phone Number                 │                   │
│  │ - Enter registered phone             │                   │
│  │ - Tap "Login"                        │                   │
│  └─────────────────────────────────────┘                    │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                    │
│  │ Step 2: OTP Verification            │                    │
│  │ - Same as registration               │                   │
│  └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  4. HOME SCREEN / DASHBOARD (Main Hub)                      │
│                                                             │
│  Top Section:                                               │
│  - Greeting: "Hello, [Name]"                                │
│  - Total invested: "₹XXX invested"                          │
│  - Current value: "₹XXX (Growth: +X%)"                      │
│                                                             │
│  Quick Action Cards:                                        │
│  ┌─────────────────────────────────────┐                    │
│  │ Card 1: "Start Learning"             │                   │
│  │ - Progress: "Module 2 of 5"          │                   │
│  │ - Button: "Continue Learning"        │                   │
│  └─────────────────────────────────────┘                    │
│  ┌─────────────────────────────────────┐                    │
│  │ Card 2: "Invest Now"                │                    │
│  │ - "Start with ₹10"                  │                    │
│  │ - Button: "Invest"                   │                   │
│  └─────────────────────────────────────┘                  │
│  ┌─────────────────────────────────────┐                  │
│  │ Card 3: "Daily Challenge"            │                  │
│  │ - Today's challenge                  │                  │
│  │ - Streak: "🔥 7 days"                │                  │
│  │ - Button: "Complete Challenge"       │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  Bottom Section:                                            │
│  - Recent Activity list                                     │
│  - "View All" link                                         │
│                                                             │
│  Navigation Options:                                        │
│  - Bottom Navigation Bar (Home, Learn, Invest, Profile)     │
│  - Or Hamburger Menu                                        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  5. LEARNING  │  │  6. INVESTMENT│  │  7. PROFILE   │
│     SCREEN    │  │     SCREEN    │  │     SCREEN    │
└───────────────┘  └───────────────┘  └───────────────┘
        │                   │                   │
        │                   │                   │
        ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│  5. LEARNING SCREEN - DETAILED FLOW                         │
│                                                             │
│  Top Section:                                               │
│  - "Learning" title                                         │
│  - Overall progress: "40% Complete"                        │
│  - XP: "1,250 XP"                                           │
│  - Level: "Level 2: Learner"                                │
│                                                             │
│  Module List:                                               │
│  ┌─────────────────────────────────────┐                  │
│  │ Module 1: "What is Money?"           │                  │
│  │ - Status: ✅ Completed (5/5)          │                  │
│  │ - Button: "Review"                    │                  │
│  └─────────────────────────────────────┘                  │
│  ┌─────────────────────────────────────┐                  │
│  │ Module 2: "Saving vs Investing"     │                  │
│  │ - Status: 🔄 In Progress (3/5)       │                  │
│  │ - Button: "Continue"                 │                  │
│  └─────────────────────────────────────┘                  │
│  ┌─────────────────────────────────────┐                  │
│  │ Module 3: "Safe Investments"        │                  │
│  │ - Status: 🔒 Locked                  │                  │
│  │ - Message: "Complete Module 2"        │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  When user taps "Continue" on Module 2:                    │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ MODULE DETAIL SCREEN                 │                  │
│  │ - Module title                      │                  │
│  │ - Lesson list (5 lessons)            │                  │
│  │ - Progress: "3/5 lessons"            │                  │
│  │ - "Start Lesson 4" button            │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ LESSON VIEW SCREEN                  │                  │
│  │ - Lesson title                      │                  │
│  │ - Content (text, images)            │                  │
│  │ - Progress: "Page 3 of 5"           │                  │
│  │ - "Previous" / "Next" buttons        │                  │
│  │ - "Take Quiz" button (at end)       │                  │
│  │ - "Mark Complete" button             │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (After completing lesson)                   │
│  ┌─────────────────────────────────────┐                  │
│  │ QUIZ SCREEN                          │                  │
│  │ - "Question 1 of 5"                  │                  │
│  │ - Question text                      │                  │
│  │ - Multiple choice options (2-4)      │                  │
│  │ - "Next" button                      │                  │
│  │ - Progress indicator                  │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (After all questions)                        │
│  ┌─────────────────────────────────────┐                  │
│  │ QUIZ RESULTS SCREEN                  │                  │
│  │ - Score: "4/5 Correct! 🎉"           │                  │
│  │ - XP earned: "+50 XP"                │                  │
│  │ - Badge earned: "🏆 Knowledge Seeker"│                  │
│  │ - "Continue Learning" button          │                  │
│  │ - "Retake Quiz" button               │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ Back to LEARNING SCREEN             │                  │
│  │ (Updated progress)                  │                  │
│  └─────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  6. INVESTMENT SCREEN - DETAILED FLOW                       │
│                                                             │
│  Top Section:                                               │
│  - Portfolio Summary                                        │
│    • Total invested: "₹500"                                 │
│    • Current value: "₹525"                                  │
│    • Total returns: "+₹25 (+5%)"                            │
│    • Simple chart (optional)                                │
│                                                             │
│  Investment Options:                                        │
│  ┌─────────────────────────────────────┐                  │
│  │ "Invest Now" Button                  │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ INVESTMENT OPTIONS SCREEN            │                  │
│  │                                       │                  │
│  │ ┌─────────────────────────────────┐  │                  │
│  │ │ Option 1: Safe Fund              │  │                  │
│  │ │ - Returns: 4-6% per year        │  │                  │
│  │ │ - Risk: Very Low                │  │                  │
│  │ │ - Min: ₹10                      │  │                  │
│  │ │ - Button: "Invest"               │  │                  │
│  │ └─────────────────────────────────┘  │                  │
│  │ ┌─────────────────────────────────┐  │                  │
│  │ │ Option 2: Growth Fund           │  │                  │
│  │ │ - Returns: 6-8% per year        │  │                  │
│  │ │ - Risk: Low                     │  │                  │
│  │ │ - Min: ₹10                      │  │                  │
│  │ │ - Button: "Invest"               │  │                  │
│  │ └─────────────────────────────────┘  │                  │
│  │ ┌─────────────────────────────────┐  │                  │
│  │ │ Option 3: Balanced Fund         │  │                  │
│  │ │ - Returns: 8-10% per year      │  │                  │
│  │ │ - Risk: Medium                 │  │                  │
│  │ │ - Min: ₹10                      │  │                  │
│  │ │ - Button: "Invest"               │  │                  │
│  │ └─────────────────────────────────┘  │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (User taps "Invest" on Safe Fund)          │
│  ┌─────────────────────────────────────┐                  │
│  │ ENTER AMOUNT SCREEN                 │                  │
│  │ - Fund name: "Safe Fund"            │                  │
│  │ - Amount input: "₹10" (minimum)     │                  │
│  │ - Slider or number input            │                  │
│  │ - Preview: "You'll invest ₹10"      │                  │
│  │ - "Continue" button                 │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ CONFIRM INVESTMENT SCREEN           │                  │
│  │ - Review: "Invest ₹10 in Safe Fund" │                  │
│  │ - Terms checkbox                    │                  │
│  │   "I understand the risks"         │                  │
│  │ - "Confirm Investment" button       │                  │
│  │ - "Back" button                     │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ INVESTMENT SUCCESS SCREEN           │                  │
│  │ - "✅ Investment successful!"        │                  │
│  │ - "You invested ₹10"                │                  │
│  │ - "View Portfolio" button            │                  │
│  │ - "Invest More" button               │                  │
│  │ - "Back to Home" button             │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps "View Portfolio")                    │
│  ┌─────────────────────────────────────┐                  │
│  │ PORTFOLIO DETAILS SCREEN            │                  │
│  │ - Current investments list          │                  │
│  │ - Each investment shows:            │                  │
│  │   • Fund name                       │                  │
│  │   • Amount: "₹100"                  │                  │
│  │   • Current value: "₹105"           │                  │
│  │   • Returns: "+₹5 (+5%)"            │                  │
│  │   • Duration: "30 days ago"        │                  │
│  │   • "View Details" button           │                  │
│  │ - Investment history                │                  │
│  │ - "Invest More" button               │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ Back to INVESTMENT SCREEN           │                  │
│  │ (Updated portfolio)                  │                  │
│  └─────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  7. PROFILE SCREEN - DETAILED FLOW                          │
│                                                             │
│  Top Section:                                               │
│  - User name or phone number                               │
│  - Level: "Level 2: Learner"                               │
│  - XP: "1,250 XP"                                           │
│  - Join date: "Member since Jan 2024"                      │
│                                                             │
│  Sections:                                                  │
│  ┌─────────────────────────────────────┐                  │
│  │ 1. ACHIEVEMENTS                     │                  │
│  │ - "You've earned 5 badges"         │                  │
│  │ - Badge grid (earned + locked)     │                  │
│  │ - Tap badge → Badge details         │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps badge)                                 │
│  ┌─────────────────────────────────────┐                  │
│  │ BADGE DETAIL SCREEN                 │                  │
│  │ - Badge icon                        │                  │
│  │ - Badge name                        │                  │
│  │ - Description                       │                  │
│  │ - Earned date                       │                  │
│  │ - "Back" button                     │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────┐                  │
│  │ 2. INVESTMENT STATS                 │                  │
│  │ - Total invested: "₹500"             │                  │
│  │ - Total returns: "+₹25"              │                  │
│  │ - Investment count: "10"             │                  │
│  │ - Longest streak: "30 days"         │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────┐                  │
│  │ 3. LEARNING STATS                   │                  │
│  │ - Lessons completed: "15/25"         │                  │
│  │ - Quizzes passed: "12/15"            │                  │
│  │ - Current streak: "7 days"           │                  │
│  │ - Total XP: "1,250 XP"               │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────┐                  │
│  │ 4. SETTINGS                          │                  │
│  │ - Language (if multilingual)        │                  │
│  │ - Notifications (on/off)            │                  │
│  │ - Biometric login (on/off)          │                  │
│  │ - Data usage (minimal/normal)       │                  │
│  │ - App version                       │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps Settings)                             │
│  ┌─────────────────────────────────────┐                  │
│  │ SETTINGS SCREEN                      │                  │
│  │ - Toggle switches                    │                  │
│  │ - Dropdown menus                     │                  │
│  │ - "Save" button                      │                  │
│  │ - "Back" button                      │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────┐                  │
│  │ 5. HELP & SUPPORT                   │                  │
│  │ - FAQ                                │                  │
│  │ - Contact support                    │                  │
│  │ - Terms & conditions                 │                  │
│  │ - Privacy policy                     │                  │
│  │ - About app                          │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps Help)                                 │
│  ┌─────────────────────────────────────┐                  │
│  │ HELP SCREEN                          │                  │
│  │ - FAQ list                           │                  │
│  │ - Contact form                       │                  │
│  │ - Links to terms/privacy             │                  │
│  │ - "Back" button                      │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────┐                  │
│  │ 6. ACCOUNT                           │                  │
│  │ - Edit profile                       │                  │
│  │ - Change phone number                │                  │
│  │ - KYC status                         │                  │
│  │ - Logout                             │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps Logout)                               │
│  ┌─────────────────────────────────────┐                  │
│  │ LOGOUT CONFIRMATION                  │                  │
│  │ - "Are you sure you want to logout?"│                  │
│  │ - "Yes, Logout" button               │                  │
│  │ - "Cancel" button                    │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Confirms logout)                           │
│  ┌─────────────────────────────────────┐                  │
│  │ Back to LOGIN SCREEN                 │                  │
│  └─────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  8. DAILY CHALLENGE SCREEN - DETAILED FLOW                  │
│                                                             │
│  Top Section:                                               │
│  ┌─────────────────────────────────────┐                  │
│  │ TODAY'S CHALLENGE CARD               │                  │
│  │ - Challenge: "Read 1 lesson"          │                  │
│  │ - Reward: "+20 XP"                   │                  │
│  │ - Status: "Not Started"               │                  │
│  │ - "Complete Challenge" button        │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (Taps "Complete Challenge")                 │
│  ┌─────────────────────────────────────┐                  │
│  │ Redirects to relevant screen:       │                  │
│  │ - If "Read lesson" → Learning Screen  │                  │
│  │ - If "Take quiz" → Quiz Screen       │                  │
│  │ - If "Invest" → Investment Screen    │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼ (After completing task)                      │
│  ┌─────────────────────────────────────┐                  │
│  │ CHALLENGE COMPLETED                  │                  │
│  │ - "✅ Challenge completed!"           │                  │
│  │ - "You earned +20 XP"                │                  │
│  │ - "Claim Reward" button              │                  │
│  └─────────────────────────────────────┘                  │
│              │                                              │
│              ▼                                              │
│  ┌─────────────────────────────────────┐                  │
│  │ Back to CHALLENGE SCREEN             │                  │
│  │ (Status: "Completed")                │                  │
│  └─────────────────────────────────────┘                  │
│                                                             │
│  Streak Section:                                            │
│  - Current streak: "🔥 7 days"                             │
│  - Visual calendar (7-day or 30-day)                       │
│  - Marked days: ✅ (completed), ❌ (missed)                 │
│  - "Keep your streak alive!"                               │
│                                                             │
│  Progress Section:                                           │
│  - Level progress: "Level 2 (1,250/2,000 XP)"               │
│  - Progress bar                                            │
│  - "Next level in 750 XP"                                  │
│                                                             │
│  Weekly Summary:                                            │
│  - "This week you:"                                        │
│    • Completed 5 challenges                                │
│    • Earned 150 XP                                         │
│    • Maintained 7-day streak                               │
└─────────────────────────────────────────────────────────────┘
```

### **NAVIGATION PATHS SUMMARY**

#### **Primary Navigation (From Home Screen):**
```
HOME SCREEN
  ├─ Tap "Start Learning" Card → LEARNING SCREEN
  ├─ Tap "Invest Now" Card → INVESTMENT SCREEN
  ├─ Tap "Daily Challenge" Card → DAILY CHALLENGE SCREEN
  ├─ Tap Profile Icon → PROFILE SCREEN
  └─ Bottom Nav Bar:
      ├─ Home Icon → HOME SCREEN (current)
      ├─ Learn Icon → LEARNING SCREEN
      ├─ Invest Icon → INVESTMENT SCREEN
      └─ Profile Icon → PROFILE SCREEN
```

#### **Learning Flow:**
```
LEARNING SCREEN
  ├─ Tap Module → MODULE DETAIL
  ├─ Tap Lesson → LESSON VIEW
  ├─ Complete Lesson → QUIZ SCREEN
  ├─ Complete Quiz → QUIZ RESULTS
  └─ Back → LEARNING SCREEN
```

#### **Investment Flow:**
```
INVESTMENT SCREEN
  ├─ Tap "Invest Now" → INVESTMENT OPTIONS
  ├─ Select Fund → ENTER AMOUNT
  ├─ Enter Amount → CONFIRM INVESTMENT
  ├─ Confirm → INVESTMENT SUCCESS
  ├─ Tap "View Portfolio" → PORTFOLIO DETAILS
  └─ Back → INVESTMENT SCREEN
```

#### **Profile Flow:**
```
PROFILE SCREEN
  ├─ Tap Badge → BADGE DETAIL
  ├─ Tap Settings → SETTINGS SCREEN
  ├─ Tap Help → HELP SCREEN
  ├─ Tap Logout → LOGOUT CONFIRMATION
  └─ Back → HOME SCREEN
```

#### **Challenge Flow:**
```
DAILY CHALLENGE SCREEN
  ├─ Tap Challenge → Redirects to relevant screen
  ├─ Complete Task → CHALLENGE COMPLETED
  └─ Back → HOME SCREEN
```

### **BACK NAVIGATION RULES**

1. **Always show back button** (except on Home)
2. **Back from Home** → Logout confirmation
3. **Back from nested screens** → Previous screen
4. **Back from Success screens** → Home or relevant screen
5. **Android back button** → Same as back button

### **DEEP LINKING PATHS** (Optional, for future)

```
microinvest://home
microinvest://learn
microinvest://learn/module/2
microinvest://invest
microinvest://invest/fund/safe
microinvest://profile
microinvest://challenge
```

---

## 🔄 **COMPLETE USER JOURNEY EXAMPLES**

### **Journey 1: New User - First Investment**
```
Splash → Onboarding → Registration → Home
  → Tap "Start Learning" → Learning Screen
  → Complete Module 1 → Quiz → Results
  → Back to Home → Tap "Invest Now"
  → Select Safe Fund → Enter ₹10 → Confirm
  → Success → View Portfolio → Back to Home
```

### **Journey 2: Existing User - Daily Usage**
```
Splash → Home (already logged in)
  → Tap "Daily Challenge" → Challenge Screen
  → Complete Challenge → Back to Home
  → Tap "Start Learning" → Continue Module
  → Complete Lesson → Quiz → Results
  → Back to Home → Check Portfolio
```

### **Journey 3: User - Profile Management**
```
Home → Profile → View Achievements
  → Tap Badge → Badge Details → Back
  → Settings → Toggle Notifications → Save
  → Back to Profile → Help → FAQ → Back
  → Back to Home
```

---

## 🎯 Minimum Screens Summary

### Core Screens (Must Have - 6 screens):
1. ✅ **Splash/Welcome** - First impression
2. ✅ **Onboarding** - Introduction
3. ✅ **Registration/Login** - Authentication
4. ✅ **Home/Dashboard** - Main hub
5. ✅ **Learning** - Education modules
6. ✅ **Investment/Portfolio** - Investing & tracking

### Recommended Screens (2 screens):
7. ⭐ **Profile/Settings** - User account
8. ⭐ **Daily Challenge** - Gamification

### Optional Screens (Can add later):
9. Help/FAQ Screen
10. Investment Details Screen
11. Transaction History Screen
12. Referral Screen

---

## 💡 Screen Design Principles

### 1. **Minimal Navigation**
- Max 3 taps to reach any feature
- Clear back button
- Bottom navigation (if needed)

### 2. **Progressive Disclosure**
- Don't show everything at once
- Unlock features gradually
- Simple, focused screens

### 3. **Offline Capable**
- All screens work offline
- Sync when online
- Clear offline indicators

### 4. **Lightweight**
- Fast loading (< 2 seconds)
- Minimal animations
- Works on low-end devices

### 5. **Consistent Design**
- Same theme (warm white & black)
- Consistent buttons
- Same navigation patterns

---

## 🚀 Implementation Priority

### Phase 1 (MVP - Week 1-2):
1. Splash Screen
2. Onboarding Screen
3. Registration/Login Screen
4. Home Screen (basic)

### Phase 2 (Core Features - Week 3-4):
5. Learning Screen
6. Investment Screen
7. Profile Screen (basic)

### Phase 3 (Enhancement - Week 5+):
8. Daily Challenge Screen
9. Enhanced Home Screen
10. Additional features

---

*This architecture ensures a minimal, focused app that works for first-time investors with limited resources and technology access.*

