## Jeans Ruiz personal site.

You can check it out here: https://jeansruiz.com/

## Running Locally

This is a Jekyll static site using the Minimal Mistakes theme.

### Prerequisites

- Ruby (installed via Homebrew or system Ruby)
- Bundler gem

### Installation & Running

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Start the development server:**
   ```bash
   bundle exec jekyll serve --livereload
   ```

3. **View the site:**
   Open your browser and navigate to:
   ```
   http://localhost:4000
   ```

The `--livereload` flag enables automatic browser refresh when you make changes to your files.

### Alternative Commands

- **Build without serving:**
  ```bash
  bundle exec jekyll build
  ```

- **Serve on a different port:**
  ```bash
  bundle exec jekyll serve --port 4001
  ```

- **Serve with drafts:**
  ```bash
  bundle exec jekyll serve --drafts
  ```

### Troubleshooting

- **SSL Certificate Issues:** The `_plugins/ssl_fix.rb` file handles SSL certificate verification issues that may occur on some systems when downloading the remote theme.

- **Port already in use:** If port 4000 is already in use, specify a different port with `--port 4001`

- **Ruby version issues:** Make sure you're using a compatible Ruby version (2.7 or higher recommended)
