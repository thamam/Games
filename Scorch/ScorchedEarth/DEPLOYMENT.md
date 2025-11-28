# Deploying Scorched Earth to Vercel

This guide will walk you through deploying your Godot game to Vercel as a web application.

## Prerequisites

Before you begin, make sure you have:

1. ✅ **Godot 4.2+** installed on your computer
2. ✅ **Vercel account** (free) - Sign up at [vercel.com](https://vercel.com)
3. ✅ **Vercel CLI** installed (optional but recommended)
4. ✅ **Git** installed and this repository cloned

## Step-by-Step Deployment Guide

### Step 1: Export HTML5 Templates in Godot

First, you need to download the HTML5 export templates for Godot 4.

1. Open Godot Editor
2. Go to **Editor → Manage Export Templates**
3. Click **Download and Install**
4. Wait for templates to download (this may take a few minutes)
5. Close the window when complete

### Step 2: Configure HTML5 Export Preset

1. In Godot, open your Scorched Earth project
2. Go to **Project → Export**
3. Click **Add** and select **Web**
4. Configure the export settings:

   **Basic Settings:**
   - **Export Path:** `web-build/index.html`
   - **Runnable:** ✅ Checked

   **Resources:**
   - **Export Mode:** Export all resources in the project

   **Options → HTML:**
   - **Custom HTML Shell:** (leave empty for default)
   - **Head Include:** (leave empty)
   - **Export Type:** Regular

   **Options → Progressive Web App:**
   - **Enabled:** ✅ Checked (optional)
   - **Offline Page:** (leave empty)
   - **Display:** Fullscreen
   - **Orientation:** Landscape
   - **Icon 144x144, 180x180, 512x512:** (optional - use icon.svg)

   **Options → Vram Texture Compression:**
   - **For Desktop:** ✅ Checked
   - **For Mobile:** ✅ Checked

5. Click **Export Project**
6. Choose `web-build/index.html` as the destination
7. Click **Save**

### Step 3: Verify Export Structure

After exporting, your `ScorchedEarth/web-build/` directory should contain:

```
web-build/
├── index.html
├── index.js
├── index.wasm
├── index.pck
├── index.icon.png (optional)
└── index.apple-touch-icon.png (optional)
```

### Step 4: Deploy to Vercel

#### Option A: Deploy via Vercel Dashboard (Easiest)

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click **Add New Project**
3. Click **Import Git Repository**
4. Connect your GitHub/GitLab/Bitbucket account (if not already connected)
5. Select your `Games` repository
6. Configure project:
   - **Framework Preset:** Other
   - **Root Directory:** `Scorch/ScorchedEarth` (click Edit and set this!)
   - **Build Command:** Leave empty
   - **Output Directory:** `web-build`
   - **Install Command:** Leave empty
7. Click **Deploy**
8. Wait 30-60 seconds for deployment to complete
9. Visit your live game at the provided URL! 🎉

#### Option B: Deploy via Vercel CLI (Advanced)

```bash
# Install Vercel CLI globally
npm install -g vercel

# Navigate to your project
cd /path/to/Games/Scorch/ScorchedEarth

# Login to Vercel
vercel login

# Deploy (first time - will ask configuration questions)
vercel

# Answer the prompts:
# Set up and deploy? Yes
# Which scope? (Select your account)
# Link to existing project? No
# Project name? scorched-earth
# In which directory is your code located? ./
# Want to override settings? Yes
# Build Command: (leave empty, press Enter)
# Output Directory: web-build
# Development Command: (leave empty, press Enter)

# Deploy to production
vercel --prod
```

### Step 5: Configure Custom Domain (Optional)

1. Go to your project dashboard on Vercel
2. Click **Settings** → **Domains**
3. Add your custom domain
4. Follow Vercel's DNS configuration instructions

## Important Notes

### Cross-Origin Headers

The `vercel.json` file includes necessary headers for WebAssembly:
- `Cross-Origin-Embedder-Policy: require-corp`
- `Cross-Origin-Opener-Policy: same-origin`

These are required for SharedArrayBuffer support in Godot 4.

### Game Performance

- **First Load:** May take 5-10 seconds to download WASM files
- **Subsequent Loads:** Browser will cache files for faster loading
- **File Size:** Expect 10-20 MB total download size

### Browser Compatibility

The game works best in:
- ✅ Chrome 90+
- ✅ Firefox 90+
- ✅ Edge 90+
- ✅ Safari 15.2+ (with some limitations)

## Troubleshooting

### Issue: Game doesn't load / black screen

**Solutions:**
1. Check browser console for errors (F12 → Console)
2. Ensure all CORS headers are set correctly
3. Try hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
4. Clear browser cache and reload

### Issue: "SharedArrayBuffer is not defined"

**Solution:**
- Verify `vercel.json` headers are properly configured
- Check browser supports SharedArrayBuffer
- Ensure HTTPS is enabled (required for SharedArrayBuffer)

### Issue: Controls don't work

**Solution:**
- Click on the game canvas to focus it
- Check that keyboard is not captured by browser (F11 fullscreen might help)
- Try refreshing the page

### Issue: Deployment failed on Vercel

**Solutions:**
1. Ensure `web-build` directory exists and contains exported files
2. Check that Root Directory is set to `Scorch/ScorchedEarth`
3. Verify `vercel.json` is in the correct location
4. Check Vercel deployment logs for specific errors

### Issue: Game runs slow in browser

**Solutions:**
- Close other browser tabs
- Disable browser extensions
- Use hardware acceleration in browser settings
- Try a different browser (Chrome usually performs best)

## Updating Your Deployment

When you make changes to the game:

1. **Re-export** from Godot to `web-build/`
2. **Commit** changes to Git:
   ```bash
   git add web-build/
   git commit -m "Update web build"
   git push
   ```
3. **Vercel auto-deploys** from Git (if connected)
   - Or run `vercel --prod` if using CLI

## Testing Locally Before Deployment

You can test the web build locally:

```bash
# Navigate to web-build directory
cd web-build

# Start a local web server (Python 3)
python3 -m http.server 8000

# Or using Python 2
python -m SimpleHTTPServer 8000

# Or using Node.js
npx http-server -p 8000

# Visit in browser
# Open: http://localhost:8000
```

**Important:** Local testing won't have the same CORS headers, so SharedArrayBuffer features may not work locally.

## File Size Optimization

To reduce download size:

1. **In Godot Export Settings:**
   - Enable **Optimize for Size** under Features
   - Disable unused engine modules
   - Use **VRAM Compression**

2. **Vercel automatically:**
   - Compresses files with Gzip/Brotli
   - Serves from global CDN
   - Caches static assets

## Security Considerations

- Game files are public and can be downloaded
- Don't include sensitive data in the build
- Source code is not exposed (compiled to WASM)
- Consider adding rate limiting if needed

## Performance Monitoring

Track your game's performance:

1. **Vercel Analytics:**
   - Enable in project settings (may require Pro plan)
   - Monitor page load times and traffic

2. **Browser DevTools:**
   - Use Performance tab to identify bottlenecks
   - Monitor Network tab for load times

## Next Steps

Once deployed, you can:

1. 📱 Share the URL with friends and players
2. 📊 Monitor analytics and player engagement
3. 🎨 Add custom domain for professional look
4. 🔧 Iterate and improve based on feedback
5. 🌐 Share on social media and game communities

## Example URLs

After deployment, your game will be accessible at:

- **Default:** `https://your-project.vercel.app`
- **Custom:** `https://scorched-earth.yourdomain.com`
- **Preview:** `https://your-project-git-branch.vercel.app`

## Resources

- 📚 [Godot HTML5 Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- 🚀 [Vercel Documentation](https://vercel.com/docs)
- 💬 [Godot Community](https://godotengine.org/community)
- 🎮 [Web Games Best Practices](https://developer.mozilla.org/en-US/docs/Games)

## Support

If you encounter issues:

1. Check Godot console for export errors
2. Review Vercel deployment logs
3. Test in different browsers
4. Check browser console for JavaScript errors
5. Consult Godot and Vercel documentation

---

**Happy Deploying! Get ready to share your game with the world! 🎮🚀**
