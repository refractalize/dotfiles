local copy_file_paths = require("copy-file-paths")

describe("GitHub origin parsing", function()
  it("parses SCP-style SSH origins", function()
    assert.are.equal(
      "https://github.com/example/project",
      copy_file_paths._parse_github_origin("git@github.com:example/project.git")
    )
  end)

  it("parses HTTPS origins", function()
    assert.are.equal(
      "https://github.com/example/project",
      copy_file_paths._parse_github_origin("https://github.com/example/project.git")
    )
  end)

  it("rejects non-GitHub origins", function()
    assert.is_nil(copy_file_paths._parse_github_origin("git@gitlab.com:example/project.git"))
  end)
end)

describe("URL construction", function()
  it("builds a file URL without a line fragment", function()
    assert.are.equal(
      "https://github.com/example/project/blob/abc123/lua/example/init.lua",
      copy_file_paths._build_url(
        "https://github.com/example/project",
        "abc123",
        "lua/example/init.lua"
      )
    )
  end)

  it("builds a URL for one line", function()
    assert.are.equal(
      "https://github.com/example/project/blob/abc123/lua/example/init.lua#L12",
      copy_file_paths._build_url(
        "https://github.com/example/project",
        "abc123",
        "lua/example/init.lua",
        12,
        12
      )
    )
  end)

  it("builds a URL for a line range and escapes the path", function()
    assert.are.equal(
      "https://github.com/example/project/blob/abc123/a%20directory/file.lua#L12-L18",
      copy_file_paths._build_url(
        "https://github.com/example/project",
        "abc123",
        "a directory/file.lua",
        12,
        18
      )
    )
  end)
end)
