class Cycodmd < Formula
  desc "CYCODEV is an AI-powered CLI toolset that brings LLMs to your terminal"
  homepage "https://cycoddocs100.z13.web.core.windows.net/"

  url "https://github.com/robch/cycod/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "a02edbd8b1991cd743c27f5a3ab9f8c0a0743b91ca2b87c32df1a6b4d5137d0d"
  
  license "MIT" # change if different
  depends_on "dotnet"

  def install
    # Keep dotnet quiet and deterministic
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SKIP_FIRST_TIME_EXPERIENCE"] = "1"
    ENV["DOTNET_NOLOGO"] = "1"

    # Restore & publish framework-dependent build into libexec
    system "dotnet", "restore", "src/cycodmd/cycodmd.csproj"
    system "dotnet", "publish",
           "src/cycodmd/cycodmd.csproj",
           "-c", "Release",
           "-o", libexec

    # Thin wrapper so `cycod` runs on PATH
    (bin/"cycod").write <<~SH
      #!/bin/bash
      exec "#{Formula["dotnet"].opt_bin}/dotnet" "#{libexec}/cycodmd.dll" "$@"
    SH
    chmod 0755, bin/"cycodmd"
  end

  test do
    # Simple smoke test; adjust if your CLI prints something else
    output = shell_output("#{bin}/cycodmd --version")
    assert_match "cycodmd", output
  end
end
