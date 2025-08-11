class Cycod < Formula
  desc "CYCODEV is an AI-powered CLI toolset that brings LLMs to your terminal"
  homepage "https://cycoddocs100.z13.web.core.windows.net/"

  url "https://github.com/robch/cycod/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "61c2f24de78866e47957843c45dc8adba8a7f10574c3f3faf35e500314a699a2"
  
  license "MIT" # change if different
  depends_on "dotnet"

  def install
    # Keep dotnet quiet and deterministic
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SKIP_FIRST_TIME_EXPERIENCE"] = "1"
    ENV["DOTNET_NOLOGO"] = "1"

    # Restore & publish framework-dependent build into libexec
    system "dotnet", "restore", "src/cycod/cycod.csproj"
    system "dotnet", "publish",
           "src/cycod/cycod.csproj",
           "-c", "Release",
           "-o", libexec

    # Thin wrapper so `cycod` runs on PATH
    (bin/"cycod").write <<~SH
      #!/bin/bash
      exec "#{Formula["dotnet"].opt_bin}/dotnet" "#{libexec}/cycod.dll" "$@"
    SH
    chmod 0755, bin/"cycod"
  end

  test do
    # Simple smoke test; adjust if your CLI prints something else
    output = shell_output("#{bin}/cycod --version")
    assert_match "cycod", output
  end
end
