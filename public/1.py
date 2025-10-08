import os, subprocess, sys, shutil

def run(cmd, check=True):
    print(f"→ {cmd}")
    res = subprocess.run(cmd, shell=True, check=check, text=True, capture_output=False)
    return res

root = os.path.dirname(os.path.abspath(__file__))
os.chdir(root)

# 1. 检查 vercel CLI
if shutil.which("vercel") is None:
    print("未检测到 Vercel CLI，正在安装……")
    run("npm install -g vercel")

# 2. 登录（仅首次）
print("如未登录，会提示扫码或邮箱验证；若已登录自动跳过。")
run("vercel login", check=False)

# 3. 构建
print("运行构建脚本……")
run("npm run build")

# 4. 部署
print("开始部署到 Vercel……")
run("vercel --prod --confirm --name watch-docs --cwd .")

print("\n✅ 部署完成。请看上方输出的访问链接，通常形如：https://watch-docs.vercel.app/")
print("后续只要：")
print("  1. 往 public/docs/ 扔文件")
print("  2. 运行 npm run build")
print("  3. 再运行 vercel --prod")
print("就能刷新目录。")
