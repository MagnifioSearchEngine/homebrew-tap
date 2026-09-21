class Magnifio < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent with coordinated sessions"
  homepage "https://github.com/MagnifioSearchEngine/homebrew-tap"
  version "0.1.0a0"

  bottle do
    root_url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "af07ecd445653481e003d0a0829002823a55759c197a281c771c418912a16e02"
    sha256 cellar: :any_skip_relocation, sequoia:       "f9e94fa382f3fbf23bd230a1ae7e64f781297cdfb52958c0d4dfe1d1ebd203cd"
  end

  depends_on "git"
  depends_on macos: :sequoia
  depends_on "python@3.14"

  on_macos do
    on_arm do
      url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a0/magnifio-0.1.0a0-macos-arm64.tar.gz"
      sha256 "58745bcea4721c9cdabb3ad9096658baff44ff58b0ab8d124868379cf94a2f5b"
    end
    on_intel do
      url "https://github.com/MagnifioSearchEngine/homebrew-tap/releases/download/v0.1.0a0/magnifio-0.1.0a0-macos-x86_64.tar.gz"
      sha256 "166012e58b6dd049e63e2051d6e49fe64f93bf0b9977771e56f499652b824d8f"
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
