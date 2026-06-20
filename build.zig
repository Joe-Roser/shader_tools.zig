const std = @import("std");
const Io = std.Io;
const Alloc = std.mem.Allocator;

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
    pub fn build_dir(self: *const ShaderBuilder, io: Io, alloc: Alloc, src_dir: []const u8, dst_dir: []const u8) !void {
        _ = self;

        const cwd = Io.Dir.cwd();
        const dir = try cwd.openDir(io, src_dir, .{ .iterate = true });
        var it = dir.iterate();

        try cwd.createDirPath(io, dst_dir);

        while (try it.next(io)) |file| {
            if (file.kind != .file) continue;

            const src = try std.fmt.allocPrint(alloc, "{s}{s}", .{ src_dir, file.name });
            defer alloc.free(src);
            const out = try std.fmt.allocPrint(alloc, "{s}{s}.spv", .{ dst_dir, file.name });
            defer alloc.free(out);

            var cmd = try std.process.spawn(io, .{ .argv = &[_][]const u8{ "glslc", src, "-O", "-Werror", "-o", out } });

            _ = try cmd.wait(io);
        }
    }

    // build a single file
    pub fn build_file(self: *const ShaderBuilder, io: Io, src: []const u8, dst: []const u8) !void {
        _ = self;

        _ = try std.process.spawn(io, .{ .argv = &[_][]const u8{ "glslc", src, "-O", "-Werror", "-o", dst } });
    }
};
