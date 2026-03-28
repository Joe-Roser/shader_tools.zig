const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b;
}
pub const ShaderBuilder = struct {
    pub const Options = struct {};
    pub fn init(o: Options) ShaderBuilder {
        _ = o;
        return .{};
    }

    /// Compiles all shaders from src to destination
    pub fn build_dir(self: *const ShaderBuilder, b: *std.Build, src_dir: []const u8, dst_dir: []const u8) !void {
        _ = self;
        const alloc = b.allocator;

        const cwd = std.fs.cwd();
        const dir = try cwd.openDir(src_dir, .{ .iterate = true });
        var it = dir.iterate();

        try cwd.makePath(dst_dir);

        while (try it.next()) |file| {
            if (file.kind != .file) continue;

            const src = try std.fmt.allocPrint(alloc, "{s}{s}", .{ src_dir, file.name });
            defer alloc.free(src);
            const out = try std.fmt.allocPrint(alloc, "{s}{s}.spv", .{ dst_dir, file.name });
            defer alloc.free(out);

            var cmd = std.process.Child.init(&[_][]const u8{ "glslc", src, "-O", "-Werror", "-o", out }, alloc);
            try cmd.spawn();

            _ = try cmd.wait();
        }
    }

    // build a single file
    pub fn build_file(self: *const ShaderBuilder, b: *std.Build, src: []const u8, dst: []const u8) !void {
        _ = self;
        const alloc = b.allocator;

        var cmd = std.process.Child.init(&[_][]const u8{ "glslc", src, "-O", "-Werror", "-o", dst }, alloc);
        try cmd.spawn();
    }
};
