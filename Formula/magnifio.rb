class Magnifio < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/MagnifioSearchEngine/homebrew-tap"
  version "0.1.0a2"

  bottle do
    root_url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f78cd05c66dd5c5d28295866e3d37f8a4b9e821152ade91d441d99a8d5b0c862"
    sha256 cellar: :any_skip_relocation, sequoia:       "42c9d8e6141e2b1700fda330ca80bae3a7bfc0bbf7a6640b6e69f5be17ef6e33"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a2/magnifio-0.1.0a2-macos-arm64.tar.gz"
      sha256 "4578e7662830af37059817dc4b7705ee5b7646485cbb3c7e0f5f6f88e333fcd3"
    end
    on_intel do
      url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a2/magnifio-0.1.0a2-macos-x86_64.tar.gz"
      sha256 "725ac82938b623f48fd6793a13099748c72904a0224351f72a5f355b242a5d69"
    end
  end

  # The prebuilt Python extensions already use relocatable @rpath IDs. Their
  # Mach-O headers do not reserve space for Homebrew's longer absolute IDs.
  preserve_rpath

  def install
    # The archive contains the exact, hash-verified runtime wheels from uv.lock.
    # Never resolve or download dependencies during installation.
    ENV["PIP_NO_INDEX"] = "1"
    venv = virtualenv_create(libexec, "python3.14", system_site_packages: false)
    venv.pip_install Dir[buildpath/"wheels/*.whl"], build_isolation: false
    %w[magnifio magnifiod llm-coord llm-coordd].each do |command|
      bin.install_symlink libexec/"bin"/command
    end
    pkgshare.install "manifest.json", "smoke_test.py"
  end

  def caveats
    <<~EOS
      Start Magnifio with: magnifio
      Connect an account with /login inside the app.

      Before upgrading or uninstalling, finish active tasks, exit Magnifio,
      and stop each profile's daemon: magnifio --profile NAME daemon stop
      Your next task starts the updated daemon. User data is preserved.
    EOS
  end

  test do
    system libexec/"bin/python", pkgshare/"smoke_test.py", bin, version.to_s
  end
end
