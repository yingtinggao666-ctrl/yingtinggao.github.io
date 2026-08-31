# Content editing guide

The site templates and styles should rarely need to be edited. Most updates happen in the content files described below.

## Landing page

Edit `_pages/landing.md`.

- `name` controls the large white name on the black opening screen.
- `introduction` controls the short statement below it.
- `button_label` controls the button text.
- Keep `button_url: /home/` unless the main Home page route changes.

## Home

Edit `_pages/about.md`.

- Edit `tagline` in `_config.yml` to change the short role line in the header.
- `position`, `affiliation`, and `location` control the introduction beside the portrait.
- `cv_url` and `scholar_url` control the two prominent links.
- Replace `assets/img/yingting-gao-portrait.jpg` with the real portrait, or change `profile.image`.
- Write the biography below the second `---` using Markdown.
- Keep `selected_papers: true` to show publications marked `selected = {true}`.

## Publications

Edit `_bibliography/reference-papers.bib`.

- Use `@inproceedings` for full papers.
- Use `@misc` for extended abstracts, posters, demos, and workshop papers.
- Every publication must contain a `project` field.
- `project` must exactly match a directory name inside `projects/`. For example,
  `project = {recy-ctronics}` matches `projects/recy-ctronics/`.
- Publication cards automatically use the linked project's `cover`; do not add a separate publication preview image.
- `pdf` can point to that project's local PDF, for example
  `/projects/recy-ctronics/assets/paper.pdf`, or to a complete external URL.
- `selected = {true}` places the entry on the Home page.
- `award` accepts text and emoji, for example `{🏆 Best Paper}`.

Copy an existing entry, give it a unique citation key, and replace the fields. Keep author names in `Last, First and Last, First` format. The build stops with a clear error when `project` is missing or does not match an existing project directory.

## Teaching

Edit `_data/teaching.yml`.

- `intro` controls the text at the top of the page.
- Add a block under `courses` for each course.
- Add course work under that course's `student_projects` list.
- Add workshop images and captions under `workshops`.
- Image paths should begin with `/assets/img/`.

Follow the existing indentation exactly because YAML uses spaces to represent structure.

## Projects

Every project is a self-contained directory with this structure:

```text
projects/
  recy-ctronics/
    index.md
    assets/
      cover.png
      paper.pdf
      process-photo.jpg
```

The directory name is the permanent `project-id`. Use lowercase letters, numbers, and hyphens. The same value must appear in three places:

1. Directory: `projects/recy-ctronics/`
2. Frontmatter: `project_id: recy-ctronics`
3. BibTeX: `project = {recy-ctronics}`

The Projects page automatically lists every `projects/*/index.md` containing a `project_id`; no separate project list needs to be maintained.

To add a project, copy one complete project directory, rename it, and change:

- `project_id` and `permalink` so they match the directory name
- `title` and `subtitle`
- `importance` for gallery order; lower numbers appear first
- `cover` and `cover_alt`
- `short_description`, shown with the title on hover
- `keywords`, shown as a comma-separated list
- `project_credits`, containing the project authors or collaborators
- `publication.citation`, plus optional `publication.pdf` and `publication.doi`.
  `doi` accepts either a full URL or a DOI identifier such as `10.1145/123.456`.
- `summary`, which appears before the hero image
- `gallery`, each containing `image`, `alt`, optional `caption`, and `width`
- `gallery_sets` for an interactive gallery with one large image and a horizontal thumbnail row. Each item accepts `image`, `thumbnail`, `alt`, and `caption`.
- `videos` for embedded players. For YouTube, store only the ID as `youtube_id`; for example, `T9UnvfFXeSw`. Local videos use `source`, optional `poster`, and optional MIME `type`.

Every project must have a `cover`. That image is automatically reused on the Projects page, the project detail page, and all linked publication cards. All cover, gallery, and local publication files must remain inside that project's `assets/` directory. Gallery width can be `full` or `half`. On phones, all images automatically become full width.

Videos are always rendered as built-in preview players on both the project page and its publication cards; do not add a plain video URL to the Markdown body.

Write the research question, process, findings, and contribution below the second `---` using ordinary Markdown headings and paragraphs.

## Images

- Portrait and teaching images: `assets/img/`
- Project-specific images and files: `projects/<project-id>/assets/`
- PDFs: `assets/pdf/`
- Use descriptive `alt` text for every meaningful image.
- Prefer consistent landscape project covers; a 4:3 or 3:2 ratio works well.
