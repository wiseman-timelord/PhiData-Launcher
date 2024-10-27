# PhyData-Launcher
Status: Alpha (do not use)

## Planner...
The plan is agents with 2 models, optimal for, thinking, coding, planning, gui interaction, etc. create pre-configuration for gui based agents for planning and getting on with tasks involving, interaction with applications and code and research, etc. for pre-configured best configuration for best current models fitting within Dynamic number of layers to GPU, then rest on system ram.
### Work Done:
- Made the launcher, to install the requirements following the information available from multiple sources, to find best info. Launcher also enables configuration of, launch commands and relevant paths, with persistence.
### Work Remaining:
- Main program requires specific functions/scripts modifying, possibly new ones added, to work with best solution for local models through built-in llama-cpp-python, find relevant files and figure out.
- When relevant files are figured out, then modify those files, delete all other in fork to cleanup, and make into drop-in files for PhiData. 
- Nemotron GGUF without matrix supposedly works on AMD GPU, if not will revert to possibly 1 model through Llama 3.2, otherwise may decide to go for other model, would have to be figured out for optimally 64GB system ram + 8GB Gpu, possibly multiple smaller deepseek 2.5 models?
- Data visualization would be nice.

## Details:
- Its a launcher for PhiData, and maybe some additional files, but the plan is to get, `Llama 3.1 70B NemoTron` and `Llama-3.1-Unhinged-Vision-8B-GGUF`, working on PhiData, then try to make a drop-in mod for that and convinience.

### Preview:
- Main Menu is like...
```
================================================================================
    PhiData-Launch
================================================================================

    1) Install PhiData Requirements
    2) Configure Arguments and Settings
    3) Configure Models Used
    4) Run PhiData Now

--------------------------------------------------------------------------------

    VENV Location:
/media/mastar/Progs-Linux_250/Programs-External/PhiData/phidata-2.5.21/phidata-venv
    Models Used:
Llama-3.1-Nemotron-70B-Instruct-HF.Q4_K_M.gguf
Llama-3.1-Unhinged-Vision-8B-q8_0.gguf

================================================================================
Selection; Menu Options 1-4, Exit Program = X: 

```
- Install Option...
```
================================================================================
    Checking and Installing Prerequisites...
================================================================================
Checking Python 3...
✓ Python 3 installed and verified
--------------------------------------------------------------------------------
Checking pip...
✓ pip installed and verified
--------------------------------------------------------------------------------
Checking python3-venv...
✓ python3-venv installed and verified
--------------------------------------------------------------------------------
Checking git...
✓ git installed and verified
--------------------------------------------------------------------------------
Setting up PhiData virtual environment...
✓ Virtual environment created at /media/mastar/Progs-Linux_250/Programs-External/phidata-venv

...

✓ PhiData and dependencies installed successfully!
================================================================================
```
- Model Selection...
```
================================================================================
    Model Configuration Menu
================================================================================


    1) Set Instruct Model Path

    2) Set Visual Model Path

--------------------------------------------------------------------------------

    Instruct Model:
Llama-3.1-Nemotron-70B-Instruct-HF.Q4_K_M.gguf

    Visual Model:
Llama-3.1-Unhinged-Vision-8B-q8_0.gguf


================================================================================
Selection; Menu Options = 1-2, Back to Main = B: 

```

## Links:
- `https://github.com/phidatahq/phidata` - Github
- `https://www.youtube.com/watch?v=T_P5wiJXkwk&pp` - PhiData on local models
- `https://www.youtube.com/watch?v=d-Kh0SvgB6k&pp` - PhiData.
