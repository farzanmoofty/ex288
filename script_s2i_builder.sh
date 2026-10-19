#!/bin/bash

mkdir -p oxy/.s2i/bin
cd oxy


cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Oxy Application</title>
</head>
<body>
  <h1>Amor vincit omnia</h1>
</body>
</html>
EOF

cat > .s2i/bin/assemble << EOF
#!/bin/bash
# This is the default assemble script
# It does NOT copy HTML files or generate info.html yet

echo "Running default assemble script..."

# Source the default assemble from the builder image
if [ -f /usr/libexec/s2i/assemble ]; then
  /usr/libexec/s2i/assemble
fi
EOF
cd ..
chmod +x oxy/.s2i/bin/assemble
