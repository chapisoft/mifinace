#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script biên dịch docs/mobile_app_proposal.md sang định dạng Microsoft Word (.docx)
Tuân thủ 100% quy chuẩn docx_export_rules.md:
- Biên dịch toàn bộ Mermaid sang ảnh PNG chất lượng cao nền trắng (-b white)
- Nhúng 14 ảnh chụp màn hình thực tế với bảng 2 cột so sánh
- Định dạng Heading, Table, Alert Callouts, Headers/Footers chuyên nghiệp
"""

import os
import re
import sys
import shutil
import subprocess
from pathlib import Path

import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

BASE_DIR = Path("/Users/micro/Source/erp/mifinace")
MD_FILE = BASE_DIR / "docs" / "mobile_app_proposal.md"
DOCX_OUTPUT = BASE_DIR / "docs" / "mobile_app_proposal.docx"
TMP_DIR = BASE_DIR / ".tmp_pandoc"
DIAGRAMS_DIR = TMP_DIR / "diagrams"

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def set_table_borders(table, color="CCCCCC", sz="4", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'<w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideV w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:left w:val="none"/>'
        f'<w:right w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def main():
    print("=== BẮT ĐẦU XUẤT BẢN TÀI LIỆU SANG DOCX ===")
    
    # 1. Tạo thư mục tạm
    if TMP_DIR.exists():
        shutil.rmtree(TMP_DIR)
    DIAGRAMS_DIR.mkdir(parents=True, exist_ok=True)
    
    # 2. Đọc file Markdown
    with open(MD_FILE, 'r', encoding='utf-8') as f:
        md_text = f.read()

    # 3. Trích xuất và render các sơ đồ Mermaid
    mermaid_blocks = []
    lines = md_text.splitlines()
    in_mermaid = False
    current_block = []
    
    for line in lines:
        if line.strip() == "```mermaid":
            in_mermaid = True
            current_block = []
        elif in_mermaid and line.strip() == "```":
            in_mermaid = False
            mermaid_blocks.append("\n".join(current_block))
        elif in_mermaid:
            current_block.append(line)
            
    print(f"-> Tìm thấy {len(mermaid_blocks)} sơ đồ Mermaid trong tài liệu.")
    
    mermaid_images = {}
    for idx, m_code in enumerate(mermaid_blocks):
        mmd_file = DIAGRAMS_DIR / f"diagram_{idx+1}.mmd"
        png_file = DIAGRAMS_DIR / f"diagram_{idx+1}.png"
        
        with open(mmd_file, 'w', encoding='utf-8') as mf:
            mf.write(m_code)
            
        print(f"   Đang render Mermaid {idx+1} sang PNG (nền trắng)...")
        # Sử dụng npx @mermaid-js/mermaid-cli với -b white và scale 2
        cmd = [
            "npx", "-y", "@mermaid-js/mermaid-cli",
            "-i", str(mmd_file),
            "-o", str(png_file),
            "-b", "white",
            "-s", "2",
            "-w", "1400"
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0 and png_file.exists():
            print(f"   ✓ Render thành công diagram_{idx+1}.png ({png_file.stat().st_size} bytes)")
            mermaid_images[idx] = png_file
        else:
            print(f"   ✗ Lỗi render Mermaid {idx+1}: {res.stderr}")

    # 4. Khởi tạo Document python-docx
    doc = Document()
    
    # Thiết lập trang A4 và lề chuẩn (Left 2.5cm, Right 2.0cm, Top 2.0cm, Bottom 2.0cm)
    for section in doc.sections:
        section.page_width = Inches(8.27)
        section.page_height = Inches(11.69)
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.9)
        section.right_margin = Inches(0.8)
        
        # Header & Footer
        header = section.header
        hp = header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun = hp.add_run("HỆ THỐNG DI ĐỘNG BMF MYANMAR — HỒ SƠ GIỚI THIỆU SẢN PHẨM & ĐỀ XUẤT GIẢI PHÁP")
        hrun.font.name = "Arial"
        hrun.font.size = Pt(8.5)
        hrun.font.color.rgb = RGBColor(148, 163, 184)
        
        footer = section.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        frun = fp.add_run("Tài liệu Mật Nội bộ — Dự án BMF Microfinance Myanmar")
        frun.font.name = "Arial"
        frun.font.size = Pt(8.5)
        frun.font.color.rgb = RGBColor(148, 163, 184)

    # Đặt style mặc định
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Arial'
    normal_style.font.size = Pt(10.5)
    normal_style.font.color.rgb = RGBColor(15, 23, 42) # Slate-900

    # 5. Phân tích nội dung và ghi vào Document
    i = 0
    mermaid_counter = 0
    total_lines = len(lines)
    
    while i < total_lines:
        line = lines[i]
        stripped = line.strip()
        
        # Bỏ qua dòng rỗng hoặc phân cách ---
        if not stripped:
            i += 1
            continue
        if stripped == "---":
            i += 1
            continue
            
        # Tiêu đề H1
        if stripped.startswith("# ") and not stripped.startswith("## "):
            h_text = stripped[2:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(14)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(18)
            run.font.bold = True
            run.font.color.rgb = RGBColor(30, 58, 138) # Primary Navy #1E3A8A
            i += 1
            continue
            
        # Tiêu đề H2
        if stripped.startswith("## ") and not stripped.startswith("### "):
            h_text = stripped[3:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(16)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(13.5)
            run.font.bold = True
            run.font.color.rgb = RGBColor(30, 64, 175) # Blue-700
            i += 1
            continue
            
        # Tiêu đề H3
        if stripped.startswith("### ") and not stripped.startswith("#### "):
            h_text = stripped[4:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(12)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(11.5)
            run.font.bold = True
            run.font.color.rgb = RGBColor(15, 23, 42)
            i += 1
            continue

        # Tiêu đề H4
        if stripped.startswith("#### "):
            h_text = stripped[5:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(3)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(10.5)
            run.font.bold = True
            run.font.color.rgb = RGBColor(37, 99, 235)
            i += 1
            continue

        # Khối Mermaid Code Block
        if stripped == "```mermaid":
            # Bỏ qua nội dung mermaid và chèn ảnh đã render
            while i < total_lines and lines[i].strip() != "```":
                i += 1
            i += 1 # bỏ dòng ```
            
            if mermaid_counter in mermaid_images:
                img_path = mermaid_images[mermaid_counter]
                if img_path.exists():
                    p = doc.add_paragraph()
                    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    p.paragraph_format.space_before = Pt(8)
                    p.paragraph_format.space_after = Pt(10)
                    run = p.add_run()
                    run.add_picture(str(img_path), width=Inches(6.4))
            mermaid_counter += 1
            continue

        # Khối Alert Callout (> [!IMPORTANT] ...)
        if stripped.startswith("> [!IMPORTANT]") or stripped.startswith("> [!NOTE]"):
            callout_lines = []
            alert_type = "LƯU Ý QUAN TRỌNG" if "IMPORTANT" in stripped else "GHI CHÚ"
            i += 1
            while i < total_lines and lines[i].strip().startswith(">"):
                c_line = lines[i].strip()[1:].strip()
                callout_lines.append(c_line)
                i += 1
                
            # Tạo bảng 1 ô làm Callout box
            c_table = doc.add_table(rows=1, cols=1)
            c_table.alignment = WD_TABLE_ALIGNMENT.CENTER
            cell = c_table.rows[0].cells[0]
            cell.width = Inches(6.5)
            set_cell_background(cell, "EFF6FF") # Light Blue
            set_cell_margins(cell, top=140, bottom=140, left=180, right=180)
            
            # Đặt viền trái dày 3pt màu xanh đậm
            tcPr = cell._tc.get_or_add_tcPr()
            borders = parse_xml(
                f'<w:tcBorders {nsdecls("w")}>'
                f'<w:left w:val="single" w:sz="24" w:space="0" w:color="1E40AF"/>'
                f'<w:top w:val="none"/>'
                f'<w:right w:val="none"/>'
                f'<w:bottom w:val="none"/>'
                f'</w:tcBorders>'
            )
            tcPr.append(borders)
            
            cp = cell.paragraphs[0]
            cp.paragraph_format.space_after = Pt(4)
            crun_tag = cp.add_run(f"[{alert_type}] ")
            crun_tag.bold = True
            crun_tag.font.color.rgb = RGBColor(30, 64, 175)
            
            full_callout_text = "\n".join(callout_lines)
            # Tách các đoạn con trong callout
            for c_idx, sub_p in enumerate(full_callout_text.split("\n")):
                if c_idx == 0:
                    target_p = cp
                else:
                    target_p = cell.add_paragraph()
                    target_p.paragraph_format.space_after = Pt(3)
                
                # Parse in đậm markdown **...**
                parts = re.split(r'(\*\*.*?\*\*)', sub_p)
                for part in parts:
                    if part.startswith("**") and part.endswith("**"):
                        r = target_p.add_run(part[2:-2])
                        r.bold = True
                        r.font.size = Pt(9.5)
                    else:
                        r = target_p.add_run(part)
                        r.font.size = Pt(9.5)
            
            # Thêm khoảng cách sau box
            p_space = doc.add_paragraph()
            p_space.paragraph_format.space_after = Pt(6)
            continue

        # Bảng Markdown (bắt đầu bằng |)
        if stripped.startswith("|") and stripped.endswith("|"):
            table_lines = []
            while i < total_lines and lines[i].strip().startswith("|"):
                table_lines.append(lines[i].strip())
                i += 1
                
            if len(table_lines) >= 2:
                # Kiểm tra nếu là bảng 2 cột chứa ảnh chụp màn hình
                first_row = [c.strip() for c in table_lines[0].split("|")[1:-1]]
                second_row = [c.strip() for c in table_lines[1].split("|")[1:-1]]
                
                is_screenshot_table = False
                data_start_idx = 2 if re.match(r'^[\s\-:|]+$', table_lines[1]) else 1
                
                for tl in table_lines[data_start_idx:]:
                    if "![" in tl and "assets/screenshots/" in tl:
                        is_screenshot_table = True
                        break
                        
                if is_screenshot_table:
                    # Tạo bảng 2 cột trưng bày ảnh màn hình
                    rows_data = []
                    for tl in table_lines[data_start_idx:]:
                        cols = [c.strip() for c in tl.split("|")[1:-1]]
                        rows_data.append(cols)
                        
                    doc_tbl = doc.add_table(rows=len(rows_data), cols=2)
                    doc_tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
                    
                    for r_idx, row in enumerate(rows_data):
                        for c_idx, cell_content in enumerate(row):
                            if c_idx >= 2:
                                break
                            doc_cell = doc_tbl.rows[r_idx].cells[c_idx]
                            doc_cell.width = Inches(3.2)
                            set_cell_background(doc_cell, "F8FAFC")
                            set_cell_margins(doc_cell, top=120, bottom=120, left=120, right=120)
                            
                            # Trích xuất đường dẫn ảnh
                            img_match = re.search(r'!\[.*?\]\((assets/screenshots/.*?)\)', cell_content)
                            p_cell = doc_cell.paragraphs[0]
                            p_cell.alignment = WD_ALIGN_PARAGRAPH.CENTER
                            
                            if img_match:
                                img_rel = img_match.group(1)
                                img_full_path = BASE_DIR / "docs" / img_rel
                                if img_full_path.exists():
                                    run_img = p_cell.add_run()
                                    run_img.add_picture(str(img_full_path), width=Inches(2.75))
                                    
                            # Tách các dòng text còn lại (chú thích)
                            text_parts = re.sub(r'!\[.*?\]\(assets/screenshots/.*?\)', '', cell_content).split("<br/>")
                            for tp in text_parts:
                                tp_str = tp.strip()
                                if tp_str:
                                    p_cap = doc_cell.add_paragraph()
                                    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
                                    p_cap.paragraph_format.space_before = Pt(3)
                                    p_cap.paragraph_format.space_after = Pt(2)
                                    
                                    # Parse Markdown in đậm
                                    sp_parts = re.split(r'(\*\*.*?\*\*)', tp_str)
                                    for spp in sp_parts:
                                        if spp.startswith("**") and spp.endswith("**"):
                                            r_cap = p_cap.add_run(spp[2:-2])
                                            r_cap.bold = True
                                            r_cap.font.size = Pt(8.5)
                                            r_cap.font.color.rgb = RGBColor(30, 58, 138)
                                        else:
                                            r_cap = p_cap.add_run(spp)
                                            r_cap.font.size = Pt(8.0)
                                            r_cap.font.color.rgb = RGBColor(71, 85, 105)
                                            
                    set_table_borders(doc_tbl, color="E2E8F0", sz="4")
                    p_sp = doc.add_paragraph()
                    p_sp.paragraph_format.space_after = Pt(6)
                    continue
                else:
                    # Bảng dữ liệu thông thường (Table Data)
                    header_cols = [c.strip() for c in table_lines[0].split("|")[1:-1]]
                    num_cols = len(header_cols)
                    
                    data_rows = []
                    start_r = 1
                    if len(table_lines) > 1 and re.match(r'^[\s\-:|]+$', table_lines[1]):
                        start_r = 2
                    for tl in table_lines[start_r:]:
                        cols = [c.strip() for c in tl.split("|")[1:-1]]
                        # Đảm bảo đủ số cột
                        while len(cols) < num_cols:
                            cols.append("")
                        data_rows.append(cols[:num_cols])
                        
                    doc_tbl = doc.add_table(rows=1 + len(data_rows), cols=num_cols)
                    doc_tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
                    
                    # Header Row
                    hdr_row = doc_tbl.rows[0]
                    for c_idx, h_text in enumerate(header_cols):
                        c = hdr_row.cells[c_idx]
                        set_cell_background(c, "1E3A8A") # Navy Blue Header
                        set_cell_margins(c, top=100, bottom=100, left=100, right=100)
                        p_hdr = c.paragraphs[0]
                        p_hdr.paragraph_format.space_after = Pt(0)
                        p_hdr.alignment = WD_ALIGN_PARAGRAPH.CENTER
                        r = p_hdr.add_run(h_text.replace("**", ""))
                        r.bold = True
                        r.font.size = Pt(9.0)
                        r.font.color.rgb = RGBColor(255, 255, 255)
                        
                    # Data Rows
                    for r_idx, d_row in enumerate(data_rows):
                        row_cells = doc_tbl.rows[r_idx + 1]
                        bg_color = "F8FAFC" if r_idx % 2 == 1 else "FFFFFF"
                        for c_idx, d_text in enumerate(d_row):
                            c = row_cells.cells[c_idx]
                            set_cell_background(c, bg_color)
                            set_cell_margins(c, top=80, bottom=80, left=100, right=100)
                            p_cell = c.paragraphs[0]
                            p_cell.paragraph_format.space_after = Pt(0)
                            
                            # Parse <br/> và in đậm
                            cell_lines = d_text.split("<br/>")
                            for cl_idx, cl in enumerate(cell_lines):
                                if cl_idx > 0:
                                    p_cell = c.add_paragraph()
                                    p_cell.paragraph_format.space_after = Pt(0)
                                    
                                parts = re.split(r'(\*\*.*?\*\*)', cl.strip())
                                for part in parts:
                                    if part.startswith("**") and part.endswith("**"):
                                        r = p_cell.add_run(part[2:-2])
                                        r.bold = True
                                        r.font.size = Pt(8.5)
                                    else:
                                        r = p_cell.add_run(part)
                                        r.font.size = Pt(8.5)
                                        
                    set_table_borders(doc_tbl, color="CBD5E1", sz="4")
                    p_sp = doc.add_paragraph()
                    p_sp.paragraph_format.space_after = Pt(6)
                    continue

        # Danh sách gạch đầu dòng (* hoặc -)
        if stripped.startswith("* ") or stripped.startswith("- "):
            p = doc.add_paragraph(style='List Bullet')
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            bullet_text = stripped[2:].strip()
            
            parts = re.split(r'(\*\*.*?\*\*)', bullet_text)
            for part in parts:
                if part.startswith("**") and part.endswith("**"):
                    r = p.add_run(part[2:-2])
                    r.bold = True
                else:
                    r = p.add_run(part)
            i += 1
            continue

        # Danh sách đánh số (1. 2. 3.)
        if re.match(r'^\d+\.\s+', stripped):
            p = doc.add_paragraph(style='List Number')
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            num_text = re.sub(r'^\d+\.\s+', '', stripped)
            
            parts = re.split(r'(\*\*.*?\*\*)', num_text)
            for part in parts:
                if part.startswith("**") and part.endswith("**"):
                    r = p.add_run(part[2:-2])
                    r.bold = True
                else:
                    r = p.add_run(part)
            i += 1
            continue

        # Đoạn văn bản bình thường (Paragraph)
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        
        parts = re.split(r'(\*\*.*?\*\*)', stripped)
        for part in parts:
            if part.startswith("**") and part.endswith("**"):
                r = p.add_run(part[2:-2])
                r.bold = True
            else:
                r = p.add_run(part)
                
        i += 1

    # 6. Lưu Document
    doc.save(str(DOCX_OUTPUT))
    print(f"=== XUẤT BẢN THÀNH CÔNG TỆP WORD (.DOCX) ===")
    print(f"-> Đường dẫn tệp tin: {DOCX_OUTPUT}")
    print(f"-> Dung lượng tệp: {DOCX_OUTPUT.stat().st_size:,} bytes")
    
    # 7. Dọn dẹp thư mục tạm
    if TMP_DIR.exists():
        shutil.rmtree(TMP_DIR)
        print("-> Đã dọn dẹp thư mục tạm .tmp_pandoc/ (Zero-Clutter).")

if __name__ == "__main__":
    main()
