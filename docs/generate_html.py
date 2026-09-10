import markdown
import os

with open('docs/effort_estimation_en.md', 'r', encoding='utf-8') as f:
    md_content = f.read()

html_body = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])

full_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Microfinance Platform - Effort Estimation</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

  @page {{
    size: A4 portrait;
    margin: 14mm 12mm 14mm 12mm;
  }}

  * {{
    box-sizing: border-box;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }}

  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 8.5pt;
    line-height: 1.45;
    color: #0f172a;
    background-color: #ffffff;
    margin: 0;
    padding: 0;
  }}

  .header-container {{
    border-bottom: 2.5px solid #1e3a8a;
    padding-bottom: 8px;
    margin-bottom: 12px;
  }}

  h1 {{
    font-size: 15pt;
    font-weight: 700;
    color: #1e3a8a;
    margin: 0 0 4px 0;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }}

  h2 {{
    font-size: 11pt;
    font-weight: 700;
    color: #1e40af;
    margin: 14px 0 6px 0;
    border-bottom: 1.5px solid #e2e8f0;
    padding-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.2px;
  }}

  .subtitle {{
    font-size: 10pt;
    font-weight: 600;
    color: #475569;
    margin: 0;
  }}

  h3 {{
    font-size: 9.5pt;
    font-weight: 600;
    color: #0f172a;
    margin: 10px 0 4px 0;
    background-color: #f8fafc;
    padding: 3px 6px;
    border-left: 3px solid #3b82f6;
  }}

  hr {{
    border: 0;
    height: 1px;
    background-color: #cbd5e1;
    margin: 10px 0;
  }}

  table {{
    width: 100%;
    border-collapse: collapse;
    margin: 6px 0 10px 0;
    font-size: 7.8pt;
    page-break-inside: auto;
  }}

  tr {{
    page-break-inside: avoid;
    page-break-after: auto;
  }}

  thead {{
    display: table-header-group;
  }}

  th {{
    background-color: #1e293b !important;
    color: #ffffff !important;
    font-weight: 600;
    text-align: left;
    padding: 5px 6px;
    border: 1px solid #334155;
    font-size: 7.6pt;
    letter-spacing: 0.2px;
  }}

  th:first-child, td:first-child {{
    text-align: center;
    width: 28px;
  }}

  td {{
    padding: 4.5px 6px;
    border: 1px solid #cbd5e1;
    vertical-align: middle;
    color: #1e293b;
  }}

  tr:nth-child(even) td {{
    background-color: #f8fafc;
  }}

  tr:hover td {{
    background-color: #f1f5f9;
  }}

  /* Highlight Total / Header Rows in Table */
  tr td strong {{
    color: #0f172a;
  }}

  td:nth-child(4), td:nth-child(5), td:nth-child(6), td:nth-child(7), td:nth-child(8), td:nth-child(9), td:nth-child(10) {{
    text-align: center;
  }}

  code {{
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 7.2pt;
    background-color: #f1f5f9;
    padding: 1px 3px;
    border-radius: 3px;
    color: #0369a1;
    border: 1px solid #e2e8f0;
  }}

  p {{
    margin: 4px 0;
  }}

  em {{
    color: #64748b;
    font-size: 7.5pt;
    font-style: italic;
    display: block;
    margin-top: 2px;
  }}

  .footer-note {{
    margin-top: 16px;
    padding: 8px 12px;
    background-color: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 7.5pt;
    color: #475569;
    display: flex;
    justify-content: space-between;
  }}
</style>
</head>
<body>
{html_body}
<div class="footer-note">
  <span>Microfinance ERP Platform • Official Technical & Effort Estimation Document</span>
  <span>Standard Viettel / Enterprise Software Estimation Model</span>
</div>
</body>
</html>
"""

with open('docs/effort_estimation_en.html', 'w', encoding='utf-8') as f:
    f.write(full_html)

print("HTML generated successfully.")
