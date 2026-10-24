# GitHub Upload Instructions (Windows PowerShell)

1. Extract this project ZIP.
2. Open PowerShell in the extracted `saas_3nf_schema` folder (the folder containing `README.md`).
3. Check Git is installed:

   ```powershell
   git --version
   ```

4. Create an empty repository on GitHub. Do not add a README or license there, because they already exist locally.
5. Initialize and commit the project:

   ```powershell
   git init
   git add .
   git status
   git commit -m "Add multi-tenant SaaS 3NF schema and tests"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
   git push -u origin main
   ```

6. Replace the example remote URL with the URL of your actual repository.
7. Open the repository page and confirm the README and folders are visible.

Before committing, check `git status` and ensure no password, access token, or local-only secret is staged.
