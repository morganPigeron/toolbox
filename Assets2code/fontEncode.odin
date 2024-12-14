package asset2code

import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"
import "core:strings"

font_encode :: proc(ttf_to_encode: string) -> encode_result {
	result := encode_result {
		result = "",
		ok     = false,
	}

	content, ok := os.read_entire_file_from_filename(ttf_to_encode)
	defer delete(content)

	if !ok {
		log.errorf("cannot read file: %v", ttf_to_encode)
		return result
	}

	sb := strings.builder_make()

	strings.write_string(&sb, "package font\n")
	strings.write_string(&sb, filepath.short_stem(ttf_to_encode))
	strings.write_string(&sb, " := [?]byte {\n")

	for b, i in content {
		print_padded(&sb, b)
		if (i + 1) % 14 == 0 {
			strings.write_string(&sb, "\n")
		}
	}
	strings.write_string(&sb, "\n")
	strings.write_string(&sb, "}\n")

	result.result = strings.to_string(sb)
	result.ok = true
	return result
}

print_padded :: proc(sb: ^strings.Builder, b: byte) {
	if b >= 100 {
		strings.write_string(sb, " ")
	} else if b >= 10 && b < 100 {
		strings.write_string(sb, "  ")
	} else {
		strings.write_string(sb, "   ")
	}
	strings.write_string(sb, fmt.tprintf("%v", b))
	strings.write_string(sb, ",")
}
