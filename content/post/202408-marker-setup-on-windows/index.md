+++
title = "Marker学习笔记（2）: 搭建 windows 环境"
date =  2024-08-25
lastmod = 2024-08-25
draft = false

tags = ["PDF", "markdown", "AI", "marker"]
summary = "Marker 是一个快速、高精度地将 PDF 转换为 Markdown 的工具。本文介绍 Marker 在 windows 上的安装和使用。"
abstract = "Marker 是一个快速、高精度地将 PDF 转换为 Markdown 的工具。本文介绍 Marker 在 windows 上的安装和使用。"

[header]
image = ""
caption = ""

+++



硬件说明： 我所使用的电脑安装有 windows 11 版本，配置有 nvidia rtx 4080 显卡，可以提供 cuda 的支持。

内容有参考这篇文档： [Marker：Windows 环境下折腾 PDF 转 Markdown](https://www.bilibili.com/read/cv29426242/)。鸣谢原作者。

## 克隆 marker 仓库

首先克隆 marker 的 github 代码仓库，后面使用时会用到：

```bash
mkdir -p ~/work/code/marker
cd ~/work/code/marker
git clone git@github.com:VikParuchuri/marker.git
cd marker
```

## 安装 marker 及其依赖

### 安装 python

要求 python 3.9+ ，我在linux 下用的是 3.10 版本，windows 下继续保持一致，下载地址：

https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe

安装过程选自定义安装，然后记得勾选自动设置windows环境变量。安装完成后，在 cmd 中验证版本：

```bash
$ pip --version
pip 23.0.1 from D:\work\soft\python\lib\site-packages\pip (python 3.10)

$ python --version
Python 3.10.11
```

在 git bash 中验证（记得如果有打开 git bash 要关闭后重新打开才能载入新的环境变量）：

```bash
$ python --version
Python 3.10.11

$ pip --version
pip 23.0.1 from D:\work\soft\python\lib\site-packages\pip (python 3.10)
```

### 特别提示： python 版本的选择

在 pytorch 官方文档中有这么一段提示：

https://pytorch.org/get-started/locally/#windows-installation

> Currently, PyTorch on Windows only supports Python 3.8-3.11

我验证过，3.12版本的确会有问题，所以千万不要选 3.12 版本。

### 安装 pytorch 和 torchvision

参考：[Start Locally | PyTorch](https://pytorch.org/get-started/locally/#windows-installation)

我选择的是 stable(2.4.0) + windows + pip + python + CUDA 12.4，因此需要运行命令：

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

安装顺利完成：

```bash
Installing collected packages: mpmath, typing-extensions, sympy, setuptools, pillow, numpy, networkx, MarkupSafe, fsspec, filelock, jinja2, torch, torchvision, torchaudio
Successfully installed MarkupSafe-2.1.5 filelock-3.13.1 fsspec-2024.2.0 jinja2-3.1.3 mpmath-1.3.0 networkx-3.2.1 numpy-1.26.3 pillow-10.2.0 setuptools-70.0.0 sympy-1.12 torch-2.4.0+cu124 torchaudio-2.4.0+cu124 torchvision-0.19.0+cu124 typing-extensions-4.9.0
```

### 安装 visual c++ 生成工具

从 https://visualstudio.microsoft.com/visual-cpp-build-tools/ 下载到 `vs_BuildTools.exe`，然后进行安装。安装内容选择 "visual c++ 生成工具", 点进去之后勾选第一项 "MSVC v143 - VS 2022 c++ x64/x86 生成工具" 和第二项 "windows 11 SDK" 即可。

为了不占用c盘空间，修改安装路径为：

- virtual studio ide：从默认的 `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools` 修改为 `D:\work\soft\Microsoft Visual Studio\2022\BuildTools`

- 下载缓存：从默认的`C:\ProgramData\Microsoft\VisualStudio\Packages` 修改为 `D:\work\soft\Microsoft\VisualStudio\Packages`

- 共享组件，工具和sdk：从默认的`C:\Program Files (x86)\Microsoft Visual Studio\Shared` 修改为 `D:\work\soft\Microsoft Visual Studio\Shared`

### 安装 detectron2

```bash
cd ~/work/code/marker
git clone https://github.com/facebookresearch/detectron2.git

pip install -e detectron2
```

注意，如果是 python 3.12 版本，会遇到报错：

```bash
ModuleNotFoundError: No module named 'torch'
```

这个问题google一圈没有修复，最后通过退回 python 3.10 版本才得以解决。

如果遇到缺少 fbgemm.dll 的报错：

```bash
      OSError: [WinError 126] 找不到指定的模块。 Error loading "D:\work\soft\python\lib\site-packages\torch\lib\fbgemm.dll" or one of its dependencies.
      [end of output]
```

则需要到下面这个地址下载：

[libomp140.x86_64.dll : Free .DLL download. (dllme.com)](https://www.dllme.com/dll/files/libomp140_x86_64/00637fe34a6043031c9ae4c6cf0a891d/download)

将得到的 libomp140.x86_64_x86-64.zip 文件解压，将里面的 libomp140.x86_64.dll 文件复制到操作系统的 `Windows\system32` 目录下即可。

如果没有安装 visual c++ 生成工具，则会报错：

```bash
    D:\work\soft\python\lib\site-packages\torch\utils\cpp_extension.py:380: UserWarning: Error checking compiler version for cl: [WinError 2] 系统找不到指定的文件。
      warnings.warn(f'Error checking compiler version for {compiler}: {error}')
    building 'detectron2._C' extension
    error: Microsoft Visual C++ 14.0 or greater is required. Get it with "Microsoft C++ Build Tools": https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

按照上面的提示安装  visual c++ 生成工具即可。

### 安装 tesseract

https://digi.bib.uni-mannheim.de/tesseract/ 

找到最新版本 tesseract-ocr-w64-setup-5.4.0.20240606.exe：

https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.4.0.20240606.exe

下载安装即可。

### 安装 Ghostscript  

安装文档：https://ghostscript.readthedocs.io/en/gs10.02.0/Install.html

下载页面：https://ghostscript.com/releases/gsdnld.html

下载得到 gs10031w64.exe，安装即可。

### 安装 CUBA

https://developer.nvidia.com/cuda-downloads

安装文件有3个G！正常下载安装接口。

### 安装 marker

```bash
pip install marker-pdf
```
安装完成时的输出：

```bash
Installing collected packages: wcwidth, filetype, urllib3, threadpoolctl, scipy, safetensors, regex, rapidfuzz, python-dotenv, pypdfium2, pydantic-core, opencv-python, joblib, idna, ftfy, charset-normalizer, certifi, annotated-types, scikit-learn, requests, pydantic, pydantic-settings, huggingface-hub, tokenizers, pdftext, transformers, texify, surya-ocr, marker-pdf
Successfully installed annotated-types-0.7.0 certifi-2024.7.4 charset-normalizer-3.3.2 filetype-1.2.0 ftfy-6.2.3 huggingface-hub-0.24.6 idna-3.8 joblib-1.4.2 marker-pdf-0.2.17 opencv-python-4.10.0.84 pdftext-0.3.10 pydantic-2.8.2 pydantic-core-2.20.1 pydantic-settings-2.4.0 pypdfium2-4.30.0 python-dotenv-1.0.1 rapidfuzz-3.9.6 regex-2024.7.24 requests-2.32.3 safetensors-0.4.4 scikit-learn-1.4.2 scipy-1.14.1 surya-ocr-0.5.0 texify-0.1.10 threadpoolctl-3.5.0 tokenizers-0.19.1 transformers-4.44.2 urllib3-2.2.2 wcwidth-0.2.13
```

## 使用 marker

先尝试转换单个文件，我以从网络上下载的 `adobe-photoshop-book-photographers-2nd.pdf` 这个680页的英文 pdf 为例。

在 cmd 下，先设置临时环境变量：

```bash
set IMAGE_DPI=192 
```

然后执行：

```bash
marker_single E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\adobe-photoshop-book-photographers-2nd.pdf E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\markdown-windows --batch_multiplier 4 --max_pages 10
```

命令执行的输出如下：

```bash
Loaded detection model vikp/surya_det3 on device cuda with dtype torch.float16
Loaded detection model vikp/surya_layout3 on device cuda with dtype torch.float16
Loaded reading order model vikp/surya_order on device cuda with dtype torch.float16
Loaded recognition model vikp/surya_rec2 on device cuda with dtype torch.float16
Loaded texify model to cuda with torch.float16 dtype
Detecting bboxes: 100%|██████████████████████████████████████████████████████████████████| 1/1 [00:01<00:00,  1.07s/it]
Recognizing Text: 100%|██████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00,  2.81it/s]
Detecting bboxes: 100%|██████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00,  1.12it/s]
Finding reading order: 100%|█████████████████████████████████████████████████████████████| 1/1 [00:00<00:00,  1.33it/s]
D:\work\soft\python\lib\site-packages\threadpoolctl.py:1214: RuntimeWarning:
Found Intel OpenMP ('libiomp') and LLVM OpenMP ('libomp') loaded at
the same time. Both libraries are known to be incompatible and this
can cause random crashes or deadlocks on Linux when loaded in the
same Python program.
Using threadpoolctl may cause crashes or deadlocks. For more
information and possible workarounds, please see
    https://github.com/joblib/threadpoolctl/blob/master/multiple_openmp.md

  warnings.warn(msg, RuntimeWarning)
Saved markdown to the E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\markdown-windows\adobe-photoshop-book-photographers-2nd folder
```

但在转换整个 pdf 文档（共680页）时，报错了：

```bash
OSError: [WinError 1455] 页面文件太小，无法完成操作。 Error loading "D:\work\soft\python\lib\site-packages\torch\lib\cublas64_12.dll" or one of its dependencies.
```

这是 windows 虚拟内存配置的太小了，尤其是我没有在 d 盘配置虚拟内存，因此修改系统配置，在 c 和 d 盘都配置固定大小为 16392 （16GB）的虚拟内存。重启电脑之后再试。

```bash
$ marker_single E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\adobe-photoshop-book-photographers-2nd.pdf E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\markdown-windows --batch_multiplier 4

Loaded detection model vikp/surya_det3 on device cuda with dtype torch.float16
Loaded detection model vikp/surya_layout3 on device cuda with dtype torch.float16
Loaded reading order model vikp/surya_order on device cuda with dtype torch.float16
Loaded recognition model vikp/surya_rec2 on device cuda with dtype torch.float16
Loaded texify model to cuda with torch.float16 dtype
Detecting bboxes: 100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 25/25 [00:26<00:00,  1.06s/it]
Recognizing Text: 100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00,  1.01it/s]
Detecting bboxes: 100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 17/17 [00:33<00:00,  1.97s/it]
Finding reading order: 100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 17/17 [00:20<00:00,  1.20s/it]
D:\work\soft\python\lib\site-packages\threadpoolctl.py:1214: RuntimeWarning:
Found Intel OpenMP ('libiomp') and LLVM OpenMP ('libomp') loaded at
the same time. Both libraries are known to be incompatible and this
can cause random crashes or deadlocks on Linux when loaded in the
same Python program.
Using threadpoolctl may cause crashes or deadlocks. For more
information and possible workarounds, please see
    https://github.com/joblib/threadpoolctl/blob/master/multiple_openmp.md

  warnings.warn(msg, RuntimeWarning)
Saved markdown to the E:\study\sky\ebook\photograph\photoshop\2024-adobe-photoshop-book-photographers-2nd\markdown-windows\adobe-photoshop-book-photographers-2nd folder
```

有一个警告，暂时先不管。检查了一下生成的内容，和 linux 下一样，没什么问题。验证 windows 下 marker 是可以正常工作的。

至于 marker 的其他使用方式，由于和 linux 下保持一致，本文就不赘述了。

## 结论

windows 下安装 marker 要比 linux 下折腾的多，主要是有几个坑，尤其 python 版本的选择要特别注意。但折腾一次之后，后面再参照这个文档安装就会容易许多。

