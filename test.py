# SPDX-FileCopyrightText: 2025 Eric Joldasov
#
# SPDX-License-Identifier: 0BSD

import module_name

print("Integer 2 reversed is:", module_name.bitreverse(2))


import pydoc

print("Module docs:", pydoc.render_doc(module_name))
print("Function docs:", pydoc.render_doc(module_name.bitreverse))
