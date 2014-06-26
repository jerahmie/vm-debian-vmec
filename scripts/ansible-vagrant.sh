#!/bin/bash
###############################################################################
# this script creates and runs /usr/bin/ansible-reprovision on the guest
#
# Arguments are (playbooks).yml

set -e
set -u

MY_SVN_CHECKOUT=""
MY_GIT_CHECKOUT="file:///shared/vm-scripts"
MY_PLAYS="${@/#/playbooks/}"  # append prefix to each argument
MY_OPTS="-e ansible_connection=local -i vagrant,"

DEPEND_COMMON="git python python-pycurl python-jinja2 python-markupsafe python-yaml"
DEPEND_DEB=$DEPEND_COMMON
DEPEND_RHEL=$DEPEND_COMMON

echo "Install / update dependencies..."
case $(lsb_release -i -s) in
    Debian|Ubuntu)
        sudo apt-get -qq update
        sudo apt-get install -y $DEPEND_DEB
        ;;
    RedHat|CentOS)
        sudo yum update
        sudo yum install -y $DEPEND_RHEL
        ;;
esac

cat << EOF > /usr/bin/ansible-reprovision
#!/bin/bash

set -e
set -u

# Fix for piping output to vagrant shell
export PYTHONUNBUFFERED=1

MY_DIR="\$(mktemp -d --suffix=-vagrant_ansible)"

if [ -z "\$@" ]; then
    # Run default plays
    MY_CMD="./bin/ansible-playbook $MY_PLAYS $MY_OPTS"
else
    # Run plays passed in as arguments
    MY_CMD="./bin/ansible-playbook $@ $MY_OPTS"
fi

#svn checkout -q "$MY_SVN_CHECKOUT" "\$MY_DIR"
echo "Attempting to clone my git repository"
git clone "$MY_GIT_CHECKOUT" "\$MY_DIR"
# Copy over modules to system
sudo cp -R "\${MY_DIR}/vm-debian/ansible/library" "/usr/share/ansible"
sudo cp "\${MY_DIR}/vm-debian/scripts/vmec_checksum.sh" "/usr/local/bin"

cat << SCRIPT
##############################################################################
### Starting local ansible provisioning
###
### Command: \$MY_CMD
###
##############################################################################
SCRIPT

cd "\${MY_DIR}/vm-debian/ansible/"
export PYTHONPATH=\$(pwd)/lib
\$MY_CMD

# clean-up
echo "Cleaning up..."
rm -rf "\$MY_DIR"

EOF

chmod +x /usr/bin/ansible-reprovision
/usr/bin/ansible-reprovision
