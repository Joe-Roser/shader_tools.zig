const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b;
}
pub const ShaderBuilder = struct {
    pub const Options = struct {};
    pub const DirOptions = struct {
        src_dir: []const u8,
        out_dir: []const u8,
    };

    pub fn init(o: Options) ShaderBuilder {
        _ = o;
        return .{};
    }

    /// Registers all shaders in src_dir to compile into out_dir
    pub fn build_dir(self: *const ShaderBuilder, b: *std.Build, o: DirOptions) !void {
        _ = self;
        var alloc = b.allocator;

        const cwd = std.fs.cwd();
        const dir = try cwd.openDir(o.src_dir, .{ .iterate = true });
        var it = dir.iterate();

        // Ensure output directory exists
        try cwd.makePath(o.out_dir);

        while (try it.next()) |file| {
            if (file.kind != .file) continue;

            const src = try std.fmt.allocPrint(alloc, "{s}{s}", .{ o.src_dir, file.name });
            defer alloc.free(src);
            const out = try std.fmt.allocPrint(alloc, "{s}{s}.spv", .{ o.out_dir, file.name });
            defer alloc.free(out);

            var cmd = std.process.Child.init(&[_][]const u8{ "glslc", src, "-O", "-Werror", "-o", out }, alloc);
            try cmd.spawn();

            _ = try cmd.wait();
        }
    }
};
