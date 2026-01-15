import numpy as np
from PIL import Image

def enhance_gray(gray_np, mode="stretch", gamma=1.0, low_pct=1, high_pct=99):
    """
    对灰度图做归一化/增强:
    - mode = "stretch": 百分位裁剪 + 线性拉伸（推荐）
    - mode = "hist": 全局直方图均衡
    - mode = "gamma": gamma 校正（先归一化再幂运算）
    返回值范围为 [0, 1]
    """
    img = gray_np.astype(np.float32)

    # 先统一到 [0,1] 粗归一化
    if img.max() > 1.0:
        img = img / 255.0

    if mode == "stretch":
        # 百分位裁剪，去掉极少数噪声点
        lo = np.percentile(img, low_pct)
        hi = np.percentile(img, high_pct)
        img = np.clip((img - lo) / max(hi - lo, 1e-6), 0, 1)

    elif mode == "hist":
        # 简单直方图均衡（global HE）
        arr = (img * 255).astype(np.uint8)
        hist, bins = np.histogram(arr.flatten(), 256, [0, 256])
        cdf = hist.cumsum()
        cdf_masked = np.ma.masked_equal(cdf, 0)
        cdf_masked = (cdf_masked - cdf_masked.min()) * 255 / (cdf_masked.max() - cdf_masked.min())
        cdf_final = np.ma.filled(cdf_masked, 0).astype('uint8')
        img = cdf_final[arr] / 255.0

    elif mode == "gamma":
        # gamma < 1 提亮暗部；gamma > 1 压暗高亮
        img = np.clip(img, 0, 1) ** gamma

    else:
        img = np.clip(img, 0, 1)

    return img


def gray_to_colored(gray_path,
                    color=(0, 156, 202),
                    # color=(0, 156, 202),

                    out_path="colored.png",
                    enhance_mode="stretch",
                    gamma=0.8):
    """
    读取灰度图 -> 增强 -> 映射到指定单色 (R,G,B) -> 保存 RGB 图
    """
    # 读灰度
    gray = Image.open(gray_path).convert("L")
    gray_np = np.array(gray)

    # 增强（归一化 / 直方图均衡 / gamma）
    norm = enhance_gray(gray_np, mode=enhance_mode, gamma=gamma)

    # 映射到指定颜色
    R, G, B = color
    colored = np.zeros((*gray_np.shape, 3), dtype=np.uint8)
    colored[..., 0] = norm * R
    colored[..., 1] = norm * G
    colored[..., 2] = norm * B

    Image.fromarray(colored).save(out_path)
    print(f"Saved to {out_path}")


if __name__ == "__main__":
    # 天青色（你可以微调）
    TIAN_QING = (255, 0, 0)

    # 方案 1：对比度拉伸 + 天青色（推荐优先尝试）
    gray_to_colored(
        gray_path=r"C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\Figures\Figure 1\200326plc1p3_L1-t210-p46.tif",
        color=TIAN_QING,
        out_path=r"C:\Users\zelinli6\OneDrive - City University of Hong Kong - Student\Documents\06paper TUNETr TMI LSA NC\Figures\Figure 1\200326plc1p3_L1-t210-p46_red.png",
        enhance_mode="stretch",  # "stretch" / "hist" / "gamma"
        gamma=0.8                 # 只在 enhance_mode="gamma" 时起作用
    )

    # 你也可以试试看直方图均衡：
    # gray_to_colored("your_gray.png", TIAN_QING, "gray_cyan_hist.png", enhance_mode="hist")

    # 或者 gamma 提亮：
    # gray_to_colored("your_gray.png", TIAN_QING, "gray_cyan_gamma.png", enhance_mode="gamma", gamma=0.6)

