import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://127.0.0.1:9223")
        context = browser.contexts[0]
        
        deepseek_page = None
        for page in context.pages:
            if "chat.deepseek.com" in page.url.lower():
                deepseek_page = page
                break
                
        if not deepseek_page:
            print("DeepSeek page not found.")
            return
            
        try:
            script = """() => {
                const msgs = document.querySelectorAll('.ds-markdown, .markdown-body, div[dir="auto"], div[class*="markdown"]');
                if (msgs.length > 0) {
                    return msgs[msgs.length - 1].innerText;
                }
                return "COULD NOT FIND MESSAGES. Body text: " + document.body.innerText.substring(0, 1000);
            }"""
            result = await deepseek_page.evaluate(script)
            with open("deepseek_pulled.txt", "w", encoding="utf-8") as f:
                f.write(result)
            print("SUCCESS")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == '__main__':
    asyncio.run(main())
