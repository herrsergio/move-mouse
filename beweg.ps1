param(
    [int]$intervalSeconds = 30,     # Time between wiggles
    [int]$JitterPixels = 1,
    [int]$DurationMinutes = 0       # 0 = run until Ctrl+C, otherwise auto-stop
)

# Load user32.dll functions
Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct INPUT {
        public int type;
        public MOUSEINPUT mi;
    }

[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MOUSEINPUT {
        public int dx;
        public int dy;
        public int mouseData;
        public int dwFlags;
        public int time;
        public System.IntPtr dwExtrainfo;
    }

[System.Runtime.InteropServices.Dllimport("user32.dll", SetLastError=true)]
    public static extern uint SendInput(uint ninputs, INPUT[] pinputs, int cbSize);
    public const int INPUT_MOUSE = 0;
    public const int MOUSEEVENTF_MOVE = 0x0001;
"@

function Send-MouseMove {
    param(
        [int]$dx,
        [int]$dy
    )

    $inp = New-Object Win32.NativeMethods+INPUT
    $inp.type = [Win32.NativeMethods]::INPUT_MOUSE
    $inp.mi.dx = $dx
    $inp.mi.dy = $dy
    $inp.mi.mouseData = 0
    $inp.mi.dwFlags = [Win32.NativeMethods]::MOUSEEVENTF_MOVE
    $inp.mi.time = 0
    $inp.mi.dwExtrainfo = [IntPtr]::Zero

    [void][Win32.NativeMethods]::SendInput(1, @($inp), [System.Runtime.InteropServices.Marshal]::SizeOf($inp))
}

# Anti-idle loop
$stopAt = if ($DurationMinutes -gt 0)
{ (Get-Date).AddMinutes($DurationMinutes) } else {
    [datetime]::MaxValue
}

while ([datetime]::Now -lt $stopAt) {
    Send-MouseMove $JitterPixels 0
    Start-Sleep -Seconds $intervalSeconds
    Send-MouseMove -$JitterPixels 0
}