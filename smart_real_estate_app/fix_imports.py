import re

files = [
    (r'C:\Users\a\Downloads\SMARTR~1\smart_real_estate_app\lib\views\home_view.dart',
     [("'../../services/api_service.dart'", "'../services/api_service.dart'"),
      ("'../../models/property_model.dart'", "'../models/property_model.dart'")]),
    (r'C:\Users\a\Downloads\SMARTR~1\smart_real_estate_app\lib\views\property_details_view.dart',
     [("'../../models/property_model.dart'", "'../models/property_model.dart'")]),
]

for filepath, replacements in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: {filepath}')

gradle_props = r'C:\Users\a\Downloads\SMARTR~1\smart_real_estate_app\android\gradle.properties'
with open(gradle_props, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace(
    'org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError',
    'org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError'
)
if 'kotlin.compiler.execution.strategy' not in content:
    content += '\nkotlin.compiler.execution.strategy=in-process\n'
with open(gradle_props, 'w', encoding='utf-8') as f:
    f.write(content)
print(f'Fixed: {gradle_props}')
print('All done!')
