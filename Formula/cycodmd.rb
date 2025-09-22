class Cycodmd < Formula
  desc "Markdown companion for Cycod"
  homepage "https://github.com/robch/cycod"
  url "https://github.com/robch/cycod/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "<fill-me>"
  license "MIT"

  depends_on "dotnet" # or "dotnet@8" if you target a specific major

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

    # Wrapper so users can run `cycodmd`
    (bin/"cycodmd").write <<~SH
      #!/bin/bash
      exec "#{Formula["dotnet"].opt_bin}/dotnet" "#{libexec}/cycodmd.dll" "$@"
    SH
    chmod 0755, bin/"cycodmd"
  end

  test do
    # Minimal smoke test
    assert_match "cycodmd", shell_output("#{bin}/cycodmd --version")
  end
end
