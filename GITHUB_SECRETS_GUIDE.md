# GitHub Secrets Configuration Guide (Simplified)

You now only need to add **ONE** secret to GitHub.

### **Step 1: Create the Secret**
1.  Go to: **Settings > Secrets and variables > Actions > New repository secret**
2.  **Name**: `FIREBASE_CONFIG_JSON`
3.  **Value**: Copy and paste the **entire** block below (including the `{` and `}`):

```json
{
  "FIREBASE_API_KEY": "AIzaSyDr6JHIReYMAT-gff_OZZtU2aaAj0zt2ho",
  "FIREBASE_AUTH_DOMAIN": "mrwaterprov1-54c3f.firebaseapp.com",
  "FIREBASE_DATABASE_URL": "https://mrwaterprov1-54c3f-default-rtdb.firebaseio.com",
  "FIREBASE_PROJECT_ID": "mrwaterprov1-54c3f",
  "FIREBASE_STORAGE_BUCKET": "mrwaterprov1-54c3f.firebasestorage.app",
  "FIREBASE_MESSAGING_SENDER_ID": "199429585160",
  "FIREBASE_APP_ID_WEB": "1:199429585160:web:919155f8d921ab0790d4bd",
  "FIREBASE_APP_ID_ANDROID": "1:199429585160:android:de08ce0929fc6f6190d4bd"
}
```

---

### **Step 2: Push the code**
Run these commands in your terminal to update the workflow to use this new single secret:
```powershell
git add .
git commit -m "Switch to simplified single-secret configuration"
git push
```

---

### **Why this is better?**
- You only have to copy/paste **once**.
- Less chance of typos in secret names.
- Everything is managed in one place.
