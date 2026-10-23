# Renders HTML (stdin) to PDF (stdout) with WeasyPrint; run by Kapa::Pdf.
# Only data: URIs are loaded, so the HTML can't make the server fetch URLs (SSRF) or read files
# (file://); layouts inline their CSS and images (Kapa::PdfHelper). Blocked URLs are reported on stderr.
import argparse
import signal
import sys

from weasyprint import CSS, HTML, default_url_fetcher

parser = argparse.ArgumentParser()
parser.add_argument("--timeout", type=int, default=30)
parser.add_argument("--zoom", type=float, default=1.0)
parser.add_argument("--width", type=float, default=8.5)   # page size in inches (default US Letter), as printed
parser.add_argument("--height", type=float, default=11.0)
parser.add_argument("--margin", type=float, default=10.0)  # page margin in mm, as printed
args = parser.parse_args()


def data_only(url, *fetch_args, **kwargs):
    if not url.startswith("data:"):
        print(f"blocked: {url[:200]}", file=sys.stderr)
        raise ValueError("Only data: URIs are allowed")
    return default_url_fetcher(url, *fetch_args, **kwargs)


# zoom scales every CSS length, page size included, so the page is set here, divided by the zoom.
z = args.zoom
page = CSS(string=f"@page {{ size: {args.width / z}in {args.height / z}in; margin: {args.margin / z}mm; }}")

# Crafted CSS can make rendering very slow; give up after the timeout.
signal.alarm(args.timeout)
# presentational_hints: honor HTML attributes like <img width="200">, as browsers do (templates use them).
HTML(string=sys.stdin.read(), url_fetcher=data_only).write_pdf(
    sys.stdout.buffer, stylesheets=[page], zoom=z, presentational_hints=True)
