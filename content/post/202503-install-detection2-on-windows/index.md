+++
title = "在 windows 上安装 detection2"
date =  2025-03-15
lastmod = 2025-03-15
draft = false

tags = ["python", "AI", "detection2"]
summary = "detection2 是 facebook 开源的深度学习目标检测库，本文介绍在 windows 上安装 detection2 的方式。"
abstract = "detection2 是 facebook 开源的深度学习目标检测库，本文介绍在 windows 上安装 detection2 的方式。"

[header]
image = ""
caption = ""

+++

detection2 是 facebook 开源的深度学习目标检测库，但是官方不支持 windows 平台，本文介绍在 windows 上安装 detection2 的方式，尤其是容易出错的地方以及解决办法。

## 背景

在2024年的8月，我当时写了一个笔记，记录了在 windows 上安装 marker 的过程，期间需要进行 detection2 的安装。

[Marker学习笔记（2）: 搭建 windows 环境]({{<relref "../202408-marker-setup-on-windows/index.md">}})

当时顺利的安装上了 detection2，以及后面的 marker。比较奇怪的是，后来我重装系统之后，再次安装时，就发现安装不上去了。

## 遇到的问题

### 安装过程和遇到的问题

为了避免多个 python 版本之间的冲突，我采用了 pyenv 来管理 python 版本。安装过程如下：

```bash
# 安装 visual c++ 生成工具 和 nvidia cuda 12.6 版本

# 安装 python 3.11.9
pyenv install 3.11.9
# 设置为全局 python 版本
pyenv global 3.11.9
# 更新 pip , setuptools 和 wheel 到最新版本
python -m pip install --upgrade pip setuptools wheel

# 安装 torch 和 torchvision
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

在这里，可以验证 torch 和 cude 都安装成功：

```bash
python -c "import torch; print(torch.__version__); print(torch.version.cuda)"
2.6.0+cu126
12.6
```

但是在继续安装 detection2 的时候:

```bash
pip install -e detectron2
```

发现一直报错 `ModuleNotFoundError: No module named 'torch'`：

```bash
Obtaining file:///D:/sky/work/code/marker/detectron2
  Installing build dependencies ... done
  Checking if build backend supports build_editable ... done
  Getting requirements to build editable ... error
  error: subprocess-exited-with-error

  × Getting requirements to build editable did not run successfully.
  │ exit code: 1
  ╰─> [23 lines of output]
      Traceback (most recent call last):
        File "C:\Users\sky\.pyenv\pyenv-win\versions\3.11.9\Lib\site-packages\pip\_vendor\pyproject_hooks\_in_process\_in_process.py", line 389, in <module>
          main()
        File "C:\Users\sky\.pyenv\pyenv-win\versions\3.11.9\Lib\site-packages\pip\_vendor\pyproject_hooks\_in_process\_in_process.py", line 373, in main
          json_out["return_val"] = hook(**hook_input["kwargs"])
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "C:\Users\sky\.pyenv\pyenv-win\versions\3.11.9\Lib\site-packages\pip\_vendor\pyproject_hooks\_in_process\_in_process.py", line 157, in get_requires_for_build_editable
          return hook(config_settings)
                 ^^^^^^^^^^^^^^^^^^^^^
        File "D:\sky\AppData\Local\Temp\pip-build-env-9y_kz0i2\overlay\Lib\site-packages\setuptools\build_meta.py", line 483, in get_requires_for_build_editable
          return self.get_requires_for_build_wheel(config_settings)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "D:\sky\AppData\Local\Temp\pip-build-env-9y_kz0i2\overlay\Lib\site-packages\setuptools\build_meta.py", line 334, in get_requires_for_build_wheel
          return self._get_build_requires(config_settings, requirements=[])
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "D:\sky\AppData\Local\Temp\pip-build-env-9y_kz0i2\overlay\Lib\site-packages\setuptools\build_meta.py", line 304, in _get_build_requires
          self.run_setup()
        File "D:\sky\AppData\Local\Temp\pip-build-env-9y_kz0i2\overlay\Lib\site-packages\setuptools\build_meta.py", line 522, in run_setup
          super().run_setup(setup_script=setup_script)
        File "D:\sky\AppData\Local\Temp\pip-build-env-9y_kz0i2\overlay\Lib\site-packages\setuptools\build_meta.py", line 320, in run_setup
          exec(code, locals())
        File "<string>", line 10, in <module>
      ModuleNotFoundError: No module named 'torch'
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
error: subprocess-exited-with-error

× Getting requirements to build editable did not run successfully.
│ exit code: 1
╰─> See above for output.

note: This error originates from a subprocess, and is likely not a problem with pip.
```

但怎么检查也检查不出问题，torch 和 cude 都安装成功, python 和 pip 的路径也正确：

```bash
python -c "import torch; print(torch.__version__); print(torch.version.cuda)"
2.6.0+cu126
12.6

$ marker which pip
/c/Users/sky/.pyenv/pyenv-win/shims/pip
$ marker which python
/c/Users/sky/.pyenv/pyenv-win/shims/python
$ which pip3
/c/Users/sky/.pyenv/pyenv-win/shims/pip3
$ which python3
/c/Users/sky/.pyenv/pyenv-win/shims/python3
```

然后就卡在这里，之后我换了 3.9/3.10/3.12 等各种 python 版本，cuda 12.4/12.6/12.8 等各种版本，都是同样的报错找不到 torch 模块。

后来我尝试了清理环境，包括：

- 在虚拟机下安装 windows 10 和 windows 11 以得到完全干净的环境
- 重新安装 pyenv
- 重新安装 python
- 重新安装 vs 2022
- 重新安装 cuda
- 重新安装 torch
- 重新安装 detection2，然后继续报错找不到 torch 模块

## 解决过程

### python 多版本管理的问题

一筹莫展之间，google `ModuleNotFoundError: No module named 'torch'` 这个错误，发现 stackoverflow 上的这个帖子：

https://stackoverflow.com/questions/54843067/no-module-named-torch

帖子中提到了一个关键点，就是安装 torch 的 python 要和后面测试的 python 版本一致。如果安装 torch 的 python 版本和测试的 python 版本不一致，就会导致找不到 torch 模块。但明显我安装的 torch 的 python 版本和安装 detection2 的 python 版本是一致的：

```bash
$ marker which pip
/c/Users/sky/.pyenv/pyenv-win/shims/pip
$ marker which python
/c/Users/sky/.pyenv/pyenv-win/shims/python
$ which pip3
/c/Users/sky/.pyenv/pyenv-win/shims/pip3
$ which python3
/c/Users/sky/.pyenv/pyenv-win/shims/python3

$ python -c "import torch; print(torch.__version__); print(torch.version.cuda)"
2.6.0+cu126
12.6

$ pip install -e detectron2
......
ModuleNotFoundError: No module named 'torch'
```

这里明显前后矛盾，python 代码打印成功说明 torch 和 cuda 都安装成功，但是 pip 安装 detectron2 的时候却报错找不到 torch 模块。

无奈之下我尝试了用 anaconda 替代 pyenv 来进行 python 版本的管理和隔离：创建名为 torch311 的 python 环境，并安装 python 3.11.11 版本。

### 非常重要的参考贴

另外发现了这个帖子，非常详细的阐述了在 windows 上安装 detection2 的整个过程，包括安装 python、torch、cuda、detection2 等，非常值得参考：

https://github.com/VikParuchuri/marker/issues/12

> The most challenging aspect of installing Marker on Windows lies in the detectron2 package developed by Facebook Research. Facebook Research is not very Windows-friendly, and they basically do not support or provide installation guidance for Windows.
> 
> 在 windows 上安装 Marker 最困难的部分是 Facebook Research 开发的 detectron2 包。Facebook Research 对 Windows 不友好，他们基本上不支持或提供 Windows 的安装指导。

### 安装 detectron2 前的准备工作

根据上面的参考贴，我尝试了新的安装方式和步骤，以下是安装 detectron2 前的准备工作：

1. 安装 visual studio 2022

    选择 “visual c++ 生成工具”, 点进去之后勾选第一项 “MSVC v143 - VS 2022 c++ x64/x86 生成工具” 和 “windows 10 SDK” / “windows 11 SDK” 即可。

    安装完成之后，检查 Microsoft Visual Studio 的安装路径下是否有如下的 cl.exe 文件

    D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.43.34808\bin\Hostx64\x64\cl.exe

    如果存在，则说明安装成功。

    （可选）设置环境变量：

    - Path，增加内容 `D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.43.34808\bin\Hostx64\x64`
    - VSINSTALLDIR = `D:\Program Files\Microsoft Visual Studio\2022\Community`

    备注：好像这两个环境变量不设置也行。

3. 安装 nvidia cuda 12.6 版本

    安装完成之后，检查 NVIDIA 的安装路径下是否有如下的 nvcc.exe 文件

    D:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6\bin\nvcc.exe

    如果存在，则说明安装成功。

3. 安装 torch 和 torchvision

    然后继续安装 torch ：

    ```bash
    python -m pip install --upgrade pip setuptools wheel

    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
    ```

    成功安装：

    ```bash
    ......
    Installing collected packages: mpmath, typing-extensions, sympy, pillow, numpy, networkx, MarkupSafe, fsspec, filelock, jinja2, torch, torchvision, torchaudio
    Successfully installed MarkupSafe-2.1.5 filelock-3.13.1 fsspec-2024.6.1 jinja2-3.1.4 mpmath-1.3.0 networkx-3.3 numpy-2.1.2 pillow-11.0.0 sympy-1.13.1 torch-2.6.0+cu126 torchaudio-2.6.0+cu126 torchvision-0.21.0+cu126 typing-extensions-4.12.2
    ```

    到这里 torch 就算是安装成功了，验证一下：

    ```bash
    (torch311) C:\Users\sky>python -c "import torch; print(torch.__version__)"
    2.6.0+cu126

    (torch311) C:\Users\sky>python -c "import torch; print(torch.__version__); print(torch.version.cuda)"
    2.6.0+cu126
    12.6
    ```

### 安装 detectron2

继续安装 detectron2 的时候，发现报错：

```bash
$ pip install -e detectron2

......

    D:\sky\work\code\marker\detectron2\detectron2\layers\csrc\nms_rotated\nms_rotated_cuda.cu(14): error: name must be a namespace name
      using namespace detectron2;
                      ^

    D:\sky\work\code\marker\detectron2\detectron2\layers\csrc\nms_rotated\nms_rotated_cuda.cu(68): error: identifier "single_box_iou_rotated" is undefined
            if (single_box_iou_rotated<T>(cur_box, block_boxes + i * 5) >
                ^

    D:\sky\work\code\marker\detectron2\detectron2\layers\csrc\nms_rotated\nms_rotated_cuda.cu(68): error: type name is not allowed
            if (single_box_iou_rotated<T>(cur_box, block_boxes + i * 5) >
                                       ^

    3 errors detected in the compilation of "D:/sky/work/code/marker/detectron2/detectron2/layers/csrc/nms_rotated/nms_rotated_cuda.cu".
    nms_rotated_cuda.cu
    error: command 'D:\\Program Files\\nvidia-cuda-tookit-12.6\\bin\\nvcc' failed with exit code 2
    [end of output]

note: This error originates from a subprocess, and is likely not a problem with pip.
```

这是编译问题，代码无法通过编译（这也是我现在非常疑惑的地方，去年8月那次我是怎么安装成功的？）。google 了一下，发现有人遇到了同样的问题：

https://github.com/facebookresearch/detectron2/issues/1601

这个 issue 后来被官方直接关闭了，解释是 detection2 根本不准备支持 windows 平台：

```bash
Unfortunately we do not provide support for windows.
```

绝望了，准备放弃，没想到这个 issue 的评论中有人给出了一个解决方案：

https://github.com/facebookresearch/detectron2/issues/1601#issuecomment-651560907

并给出了一个解决的办法：

```bash
//NOTE: replace relative import
/*
#ifdef WITH_CUDA
#include "../box_iou_rotated/box_iou_rotated_utils.h"
#endif
// TODO avoid this when pytorch supports "same directory" hipification
#ifdef WITH_HIP
#include "box_iou_rotated/box_iou_rotated_utils.h"
#endif
*/
#include "box_iou_rotated/box_iou_rotated_utils.h"
```

我参考这个修改，顺利通过编译，detection2 终于完成在 windows 上的安装。

> 备注：这个issue在上面介绍 detection2 在 windows 上安装的参考贴中也有提到，但是当时没有在意，导致走了不少弯路。

## 安装 marker 进行验证

继续安装 marker 进行验证，参考之前安装 marker 的笔记：

[Marker学习笔记（2）: 搭建 windows 环境]({{<relref "../202408-marker-setup-on-windows/index.md">}})


### 安装 tesseract 和 Ghostscript

安装 tesseract 和 Ghostscript 的步骤和之前安装 marker 的笔记一样，这里不再赘述。

### 安装 marker

```bash
pip install marker-pdf
``` 

输出为：


```bash
Collecting marker-pdf
......
Installing collected packages: wcwidth, filetype, websockets, urllib3, typing-inspection, threadpoolctl, soupsieve, sniffio, scipy, safetensors, regex, rapidfuzz, python-dotenv, pypdfium2, pydantic-core, pyasn1, Pillow, opencv-python-headless, markdown2, joblib, jiter, idna, h11, ftfy, distro, charset-normalizer, certifi, cachetools, annotated-types, scikit-learn, rsa, requests, pydantic, pyasn1-modules, httpcore, beautifulsoup4, anyio, pydantic-settings, markdownify, huggingface-hub, httpx, google-auth, tokenizers, pdftext, google-genai, anthropic, transformers, surya-ocr, marker-pdf
  Attempting uninstall: Pillow
    Found existing installation: pillow 11.0.0
    Uninstalling pillow-11.0.0:
      Successfully uninstalled pillow-11.0.0
Successfully installed Pillow-10.4.0 annotated-types-0.7.0 anthropic-0.46.0 anyio-4.8.0 beautifulsoup4-4.13.3 cachetools-5.5.2 certifi-2025.1.31 charset-normalizer-3.4.1 distro-1.9.0 filetype-1.2.0 ftfy-6.3.1 google-auth-2.38.0 google-genai-1.5.0 h11-0.14.0 httpcore-1.0.7 httpx-0.28.1 huggingface-hub-0.29.3 idna-3.10 jiter-0.9.0 joblib-1.4.2 markdown2-2.5.3 markdownify-0.13.1 marker-pdf-1.6.1 opencv-python-headless-4.11.0.86 pdftext-0.6.2 pyasn1-0.6.1 pyasn1-modules-0.4.1 pydantic-2.11.0b1 pydantic-core-2.31.1 pydantic-settings-2.8.1 pypdfium2-4.30.0 python-dotenv-1.0.1 rapidfuzz-3.12.2 regex-2024.11.6 requests-2.32.3 rsa-4.9 safetensors-0.5.3 scikit-learn-1.6.1 scipy-1.15.2 sniffio-1.3.1 soupsieve-2.6 surya-ocr-0.13.0 threadpoolctl-3.6.0 tokenizers-0.21.1 transformers-4.49.0 typing-inspection-0.4.0 urllib3-2.3.0 wcwidth-0.2.13 websockets-14.2
```

### 验证 marker

测试一下，转换一个 pdf 文件试试：

```bash
$ marker_single D:\temp\adobe-photoshop-book-photographers-2nd.pdf

Downloading layout model...: 100%|
......
Running OCR Error Detection: 100%|
Detecting bboxes: 0it [00:00, ?it/s]
......
Detecting bboxes: 100%|[00:01<00:00,  3.37it/s]
Recognizing Text: 100%| [00:11<00:00,  1.84it/s]
Recognizing tables: 100%|[00:03<00:00,  2.11it/s]
Saved markdown to D:\sky\work\soft\anaconda\envs\torch311\Lib\site-packages\conversion_results\adobe-photoshop-book-photographers-2nd
Total time: 107.72942638397217
```

至此 detection2 和 marker 安装完成。

## 总结

经过这么一番折腾，终于在 windows 上安装上了 detection2 和 marker。鸣谢上面提到的参考贴，以及 stackoverflow 上的帖子，以及 github 上的 issue 和评论。本着人人为我，我为人人的精神，我也将整个过程记录下来，希望对其他遇到类似问题的同学有所帮助。

但依然有两个疑问我至今没能想明白：

1. 去年8月那次我是怎么安装成功的？毕竟从上面的过程上看，detection2 的安装过程中必须要修改源码才能编译通过，而需要修改源码这么关键的步骤，以我记录笔记的习惯，绝无可能疏漏。
2. pyenv 和 anaconda 下同样的操作，为什么 pyenv 下安装 detection2 会报错找不到 torch 模块？


