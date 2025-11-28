# Vercel Deployment - Quick Start (5 Minutes)

Deploy your Scorched Earth game to the web in 5 minutes!

## What You Need

- ✅ Godot 4.2+ installed
- ✅ Free Vercel account ([sign up here](https://vercel.com))
- ✅ This game project

## 3-Step Deployment

### Step 1: Export to HTML5 (2 minutes)

1. Open the project in **Godot 4.2+**

2. Download export templates:
   - **Editor → Manage Export Templates**
   - Click **Download and Install**
   - Wait for download to complete

3. Export the game:
   - **Project → Export**
   - Click **Add** → Select **Web**
   - Set **Export Path:** `web-build/index.html`
   - Click **Export Project**
   - Save to `web-build/index.html`

### Step 2: Push to GitHub (1 minute)

```bash
cd /path/to/Games/Scorch/ScorchedEarth

# Add the web build
git add web-build/
git commit -m "Add HTML5 web build"
git push
```

### Step 3: Deploy to Vercel (2 minutes)

1. Go to **[vercel.com](https://vercel.com)** and sign in

2. Click **Add New Project** → **Import Git Repository**

3. Select your **Games** repository

4. Configure:
   - **Root Directory:** Click **Edit** → Set to `Scorch/ScorchedEarth`
   - **Framework Preset:** Other
   - **Build Command:** (leave empty)
   - **Output Directory:** `web-build`

5. Click **Deploy**

6. **Done!** 🎉 Visit your game at the provided URL

## Your Game is Live! 🚀

Share your URL:
- `https://your-project.vercel.app`

## Next Steps

- 📱 Share with friends
- 🎮 Play in any browser
- 🔧 Update by re-exporting and pushing to Git

## Troubleshooting

**Black screen?**
- Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
- Check browser console (F12) for errors

**Controls not working?**
- Click on the game to focus it
- Make sure browser has keyboard focus

**Need more help?**
- See full guide: [DEPLOYMENT.md](DEPLOYMENT.md)

---

**That's it! Your game is now playable online! 🎮**
