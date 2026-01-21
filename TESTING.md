# Testing Guide for HapticTimer

## In-App Purchase Testing

### Local Testing (StoreKit Configuration)

The app includes `Configuration.storekit` for local testing without real money.

#### Setup:
1. Open the project in Xcode
2. Go to **Product → Scheme → Edit Scheme...**
3. Select **Run** → **Options** tab
4. Set **StoreKit Configuration** to **Configuration.storekit**

#### Test Scenarios:

**1. Purchase Premium**
- Launch app (free user by default)
- Go to Saved Timers tab → Paywall shows
- Tap "Upgrade for $4.99"
- Complete test purchase (no real money)
- ✅ Verify: Paywall disappears, can save timers, add 5 haptic points, access colors

**2. Restore Purchases**
- With premium active: Debug → StoreKit → Manage Transactions
- Refund the purchase
- ✅ Verify: App reverts to free (3 points, no save, no colors)
- Tap "Restore Purchase" in paywall
- ✅ Verify: Premium features return

**3. Purchase Cancellation**
- Tap "Upgrade"
- On purchase sheet, tap **Cancel** or press back
- ✅ Verify: Returns to paywall, no error shown

**4. Network Failure Simulation**
- Debug → StoreKit → Disable Purchases
- Try to purchase
- ✅ Verify: Error message appears
- Debug → StoreKit → Enable Purchases

**5. Test Premium Features**
After purchasing:
- ✅ Add 4th and 5th haptic points (free allows max 3)
- ✅ Save timer configurations (free shows paywall)
- ✅ Access color picker (free doesn't see button)

### Sandbox Testing (Real App Store Environment)

For testing before production release:

#### Setup:
1. **Create Sandbox Tester Account**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Users and Access → Sandbox Testers
   - Click **+** to add tester
   - Use a **new email** (not associated with any Apple ID)
   - Remember password

2. **Sign Out of Real Apple ID**:
   - On device: Settings → [Your Name] → Media & Purchases → Sign Out
   - DO NOT sign out of iCloud, only Media & Purchases

3. **Run App from Xcode**:
   - DO NOT use StoreKit Configuration in scheme
   - Build and run on physical device
   - When prompted for Apple ID, use sandbox tester credentials

4. **Test Purchase**:
   - Purchase will use sandbox environment
   - Shows [Environment: Sandbox] in purchase sheet
   - No real money charged

#### Sandbox Test Checklist:
- ✅ Purchase completes successfully
- ✅ Receipt validation works
- ✅ Restore purchases works after reinstall
- ✅ Purchase persists across app launches
- ✅ Family Sharing works (if enabled)

### TestFlight Testing

Final pre-launch testing with real users:

1. Upload build to App Store Connect
2. Add internal or external testers
3. Testers use sandbox accounts
4. Collect feedback on purchase flow

## Haptic Testing

### Test All 6 Patterns:
1. Set timer to 2:00
2. Add haptic points at: 1:30, 1:00, 0:30, 0:00
3. Assign different patterns to each
4. Start timer
5. ✅ Verify: Each pattern fires at correct time with distinct feel

### Pattern Characteristics:
- **Pulse**: Single smooth bump (0.5s)
- **Heartbeat**: Two quick thumps (lub-dub)
- **Wave**: Rising and falling over 2 seconds
- **Staccato**: Four sharp taps
- **Rolling**: Continuous rumble with variation
- **Alert**: Three medium spaced pulses

### Haptic Preview:
- Tap any point → Pattern selector
- Tap eye icon next to each pattern
- ✅ Verify: Immediate haptic feedback for that pattern

## Timer Testing

### Basic Flow:
1. Launch app
2. Default: 10:00 timer
3. Tap center time → Change to 5:00
4. Add haptic point (appears randomly, snaps to 30-sec intervals)
5. Long-press point → Drag around circle
6. ✅ Verify: Point follows finger smoothly, snaps to 30-sec on release
7. Tap point (no long press) → Pattern selector opens
8. Start timer → Progress circle drains clockwise
9. ✅ Verify: Haptics fire at correct times

### Edge Cases:
- Timer < 30 seconds: Should prevent start (minimum 30s)
- Timer at 0:00: Completes, auto-resets after 1 second
- Pause/Resume: Progress continues from where it left off
- Reset while running: Returns to full duration

## Saved Timers Testing (Premium)

1. Purchase premium (using test purchase)
2. Create a timer: 5:00 with 3 haptic points
3. Select custom color (e.g., Pink)
4. Tap save icon → Name it "Morning Stretch"
5. Go to Saved tab
6. ✅ Verify: "Morning Stretch" appears with pink dot, 5:00, 3 points
7. Tap it → Loads instantly, switches to Timer tab
8. ✅ Verify: Time is 5:00, all 3 points present, color is pink
9. Swipe to delete from Saved tab
10. ✅ Verify: Configuration deleted

## Color Customization Testing (Premium)

1. With premium active
2. Tap color circle button next to "Add Vibration Point"
3. ✅ Verify: 10 colors shown in grid
4. Select each color
5. ✅ Verify: Circle changes color immediately
6. Save timer with color
7. Load timer
8. ✅ Verify: Saved color restored

## Gesture Testing

### Tap vs Long Press:
1. Add haptic point
2. **Quick tap** point → Pattern selector opens
3. Close selector
4. **Long press (0.3s) + drag** → Point moves
5. ✅ Verify: Can distinguish between tap and drag

### Drag Feel:
- Should feel smooth, not stuttery
- Medium haptic when drag starts
- Light haptic when released
- Time label follows point
- Point snaps to nearest 30-sec interval on release

## Performance Testing

- [ ] App launches quickly (< 2 seconds)
- [ ] Timer updates are smooth (no dropped frames)
- [ ] Dragging points is responsive
- [ ] Pattern selector opens instantly
- [ ] Haptics fire precisely at scheduled times
- [ ] Memory usage stable over 10+ minute timer session

## Known Limitations

- Haptics don't fire when app is backgrounded (iOS limitation without notifications)
- Points limited to 30-second intervals (by design)
- Minimum 30-second spacing between points (prevents collision)

## Pre-Launch Checklist

Before submitting to App Store:

- [ ] All 6 haptic patterns work on physical device
- [ ] Purchase flow works in sandbox
- [ ] Restore purchases works
- [ ] Saved timers persist after app restart
- [ ] All 10 colors display correctly
- [ ] Timer countdown is accurate (test with stopwatch)
- [ ] No memory leaks during long sessions
- [ ] Works on iPhone SE (smallest screen)
- [ ] Works on iPhone 15 Pro Max (largest screen)
- [ ] Dark mode looks good
- [ ] Onboarding flow complete (if added)
- [ ] Privacy policy updated with purchase info
- [ ] App Store screenshots prepared
- [ ] App Store description written
- [ ] Keywords optimized for search
