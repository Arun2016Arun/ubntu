#!/bin/bash
set -e
trap 'catch $? $LINENO' ERR
catch() {
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "${RED}Error $1 occurred on line $2${NC}"
    exit 1
}
VERSION="2.4.6"
red_text="\e[31m
    ____    ____     __     ___     ____    _____
   / __ \  / __ \   / /    /   |   / __ )  / ___/
  / / / / / / / /  / /    / /| |  / __  |  \__ \ 
 / /_/ / / /_/ /  / /___ / ___ | / /_/ /  ___/ / 
/_____/  \___\_\ /_____//_/  |_|/_____/  /____/  
                                                 
\e[32mVersion $VERSION is going to be installed...\e[0m

\e[34m******************************
*                              *
*   Happy installing DQLabs!   *
*                              *
******************************\e[0m

\e[36mEnjoy your new platform!\e[0m
"

echo -e "$red_text"
echo
if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as root" 1>&2
  exit 1
fi
echo -n "DQLabs installation is on onpremise (yes/no): "
read onprem
if [[ "$onprem" == [yY] || "$onprem" == [yY][eE][sS] ]];
then
sudo -n -l -U $USER |grep NOPASSWD
if [ $? -ne 0 ]; then
echo -e "\e[1;45m "Need user with sudo permission without password" \e[0m"
echo -e "\e[1;45m "Please follow the installation document and continue script" \e[0m"
exit 0
else
    echo "User have sudo permission without password"
fi
else
   echo "User have sudo permission without password"
   fi

print_warning() {
    local message="$1"
    local width=${#message}
    printf "\e[31m"
    echo "â•”$(printf 'â•%.0s' $(seq 1 $((width + 2))))â•—"
    echo "â•‘ $message â•‘"
    echo "â•š$(printf 'â•%.0s' $(seq 1 $((width + 2))))â•"
    printf "\e[0m"
}

#!/bin/bash

echo -n "Do you have PostgreSQL database? (yes/no): "
read install_postgresql

if [[ "$install_postgresql" == "yes" ]]; then
    
    echo -n "Enter the PostgreSQL Host: "
    read PG_HOST
    echo -n "Enter the PostgreSQL username: "
    read PG_USERNAME
    echo -n "Enter the PostgreSQL password: "
    read -s PG_PASSWORD
    echo
    echo -n "Enter the PostgreSQL Database name: "
    read PG_DB_NAME
    echo -n "Enter the PostgreSQL Port no: "
    read PG_PORT_NO
    echo

    sudo apt-get update
    sudo apt-get install -y ncat

    if nc -z "$PG_HOST" "$PG_PORT_NO"; then
        cd ~/
        wget https://s3.amazonaws.com/erwin-2.0/code/linux/postgres_test_connection.py
        sudo apt install python3-pip -y
        pip3 install psycopg2-binary

        export PG_HOST
        export PG_USERNAME
        export PG_PASSWORD
        export PG_DB_NAME
        export PG_PORT_NO

       python3 ~/postgres_test_connection.py
        if [[ $? -ne 0 ]]; then
            echo -e "\033[31mPython script failed. Exiting.\033[0m"
            rm -rf ~/postgres_test_connection.py
            exit 1
        fi
        rm -rf ~/postgres_test_connection.py
        echo -e "\e[32mTelnet test successful! Host $PG_HOST on port $PG_PORT_NO is reachable.\e[0m"
        echo
    else
        error_message="Telnet test failed. Host $PG_HOST on port $PG_PORT_NO is not reachable."
        print_warning "$error_message"
        echo -e "\e[31mPlease check the PostgreSQL configuration file for resolving this issue.\e[0m"
        echo
        exit 1
    fi
else
    echo "PostgreSQL installation not confirmed. Exiting."
fi

echo -n "Are you using DNS pointing to DQLabs installing server (yes/no): "
read loadbalancer

echo user input is $loadbalancer
if [[ "$loadbalancer" == [yY] || "$loadbalancer" == [yY][eE][sS] ]];
then
        echo -n "Please provide your loadbalancer DNS or dns pointing to dqlabs installing server (foo.subdomain.com): "
        read DNSa
        echo -n "Please re-enter your loadbalancer DNS or dns pointing to dqlabs installing server (foo.subdomain.com): "
        read DNSb
        if [[ "$DNSa" == "$DNSb" ]];
        then
                echo -e "\e[32mProvided DNS name is : $DNSa\e[0m"
                echo
                echo -n "Is DNS name runs on ssl (http or https): "
                read ssl

        else
                echo -e "\e[1;45m "Provided DNS name mismatch $DNSa  $DNSb"  \e[0m"
                exit 0
        fi
elif [[ "$loadbalancer" == [nN] || "$loadbalancer" == [nN][oO] ]];
then
        echo -n "Need to run Dqlabs in private IP or public IP (private or public ): "
        read machineip
        if [[ "$machineip" == "private" || "$machineip" == "public" || "$machineip" == "localhost" ]];
        then
                systemip=$machineip
                        echo -n "Does machine runs on ssl (http or https): "
                read ssl
        else
                echo -e "\e[1;45m  "Provide input $sytemip does not match with the current config, please re-run again with correct option whether its public or private" \e[0m"
                exit 0
        fi
else
         echo "Localhost selected for DQLabs application -------------------------------->>"
         echo "Localhost selected for DQLabs application -------------------------------->>"
         machineip=localhost
 fi
 if [[ "$ssl" == 'http' ]];then
        echo -n "Please provide the port number on which Dqlabs Access by web browser(80 0r whatevever port execpt 8000 & 8080): "
       read port
else
   port=443
 echo "\e[1;45m "Dqlabs running $port"  \e[0m"
fi

echo -n "Please provide admin account user mail ID (eg:admin@dqlabs.ai): "
read username
echo -n "Please provide admin account password (eg:DqL@b5): "
read password
echo username=$username
echo password=$password
####################
echo
if [ -f /etc/needrestart/needrestart.conf ]; then
    sudo sed -i "s/#\$nrconf{restart} = 'i'/\$nrconf{restart} = 'a'/g" /etc/needrestart/needrestart.conf
fi
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.10 -y
sudo ln -s /usr/bin/python3.10 /usr/bin/python
sudo apt install python3.10-distutils -y
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3.10 get-pip.py
sudo chown -R $USER.root /usr/bin/python
export PATH="/usr/local/bin:$PATH"
source ~/.bashrc
sudo apt-get install python3.10-dev -y
sudo apt-get install libpq-dev -y
sudo apt install p7zip-full -y
sudo apt-get install pkg-config libxml2-dev libxmlsec1-dev libxmlsec1-openssl -y

sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update -y
sudo apt -y install openjdk-11-jdk openjdk-11-jre


wget https://s3.amazonaws.com/erwin-2.0/code/linux/node-v16.15.0-linux-x64.tar.gz -P /home/$USER/
cd /home/$USER/
tar -xvf node-v16.15.0-linux-x64.tar.gz
rm -rf node-v16.15.0-linux-x64.tar.gz
mv node-v16.15.0-linux-x64 node
echo "export NODEJS_HOME=/home/$USER/node" >> ~/.bashrc
echo "export PM2_HOME=/home/$USER/node_modules/pm2/" >> ~/.bashrc
echo "export AIRFLOW_HOME=~/airflow" >> ~/.bashrc
echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/$USER/node/bin:/usr/local/spark/bin:/home/$USER/node_modules/pm2/bin" >> ~/.bashrc
export NODEJS_HOME=/home/$USER/node

export PATH="$PATH:/home/ubuntu/.local/bin"

if [[ "$install_postgresql" == "no" ]];
then
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
        sudo apt update
        sudo apt install postgresql-15 postgresql-server-dev-12 -y
        systemctl is-enabled postgresql
        sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Intel1234';"
        sudo -u postgres psql -c "create database dqlabs;"
        sudo -u postgres psql -c "CREATE DATABASE airflow_db;"
        sudo -u postgres psql -c "CREATE USER airflow_user WITH PASSWORD 'airflowuser';"
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;"
        sudo -u postgres psql -c "ALTER USER airflow_user SET search_path = public;"
        systemctl is-enabled postgresql
        sudo mv /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/main/pg_hba-bck.conf
        sudo wget https://s3.amazonaws.com/erwin-2.0/code/linux/pg_hba.conf -P /etc/postgresql/15/main/
        sudo service postgresql@15-main start
fi

sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt update
sudo apt install apache2 -y
sudo a2enmod headers proxy proxy_http proxy_connect rewrite ssl
sudo rm -rf /etc/apache2/sites-enabled/*
sudo wget https://s3.amazonaws.com/erwin-2.0/code/linux/dqlabs.conf -P /etc/apache2/sites-enabled/
sudo systemctl enable apache2

sudo touch /etc/apt/sources.list.d/mssql-release.list
sudo chown -R $USER.root /etc/apt/sources.list.d/mssql-release.list
sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install -y unixodbc-dev
cd /tmp/
sudo apt install alien libaio1 -y
wget https://s3.amazonaws.com/erwin-2.0/code/linux/oracle-instantclient-basiclite-21.4.0.0.0-1.x86_64.rpm
wget https://s3.amazonaws.com/erwin-2.0/code/linux/oracle-instantclient-odbc-21.4.0.0.0-1.x86_64.rpm
sudo alien -i oracle-instantclient*
echo /usr/lib/oracle/12.1/client64/lib/ | sudo tee  /etc/ld.so.conf.d/oracle.conf && sudo chmod o+r /etc/ld.so.conf.d/oracle.conf
echo 'export ORACLE_HOME=/usr/lib/oracle/12.1/client64' | sudo tee /etc/profile.d/oracle.sh && sudo chmod o+r /etc/profile.d/oracle.sh
 . /etc/profile.d/oracle.sh
sudo apt install unixodbc -y

sudo apt-add-repository universe -y
sudo apt-get update
sudo apt-get install python-setuptools -y
sudo apt-get install libmysqlclient-dev -y
sudo apt-get install libssl-dev -y
sudo apt-get install libkrb5-dev -y
#pip install python-dotenv


export AIRFLOW_HOME=~/airflow
#pip3.10 install --upgrade pip
 pip install pydantic==1.10.10
 #pip install testresources  --no-warn-script-location
 #pip install apache-airflow==2.8.1
 #pip install typing_extensions  --no-warn-script-location
 #pip install cffi
 #pip install pyarrow==6.0.1
 #pip install pendulum==2.1.2
 #pip install Flask-Session==0.5.0
 #pip install connexion==2.14.2

wget https://s3.amazonaws.com/erwin-2.0/code/linux/application-code/$VERSION/DQLabs-Airflow.7za -P ~/
wget https://s3.amazonaws.com/erwin-2.0/code/linux/application-code/$VERSION/DQLabs-Client.7za -P ~/
wget https://s3.amazonaws.com/erwin-2.0/code/linux/application-code/$VERSION/DQLabs-Server.7za -P ~/
wget https://s3.us-east-1.amazonaws.com/erwin-2.0/code/linux/application-code/$VERSION/site-packages.7za -P ~/
wait $!
cd ~/
7za x DQLabs-Server.7za
7za x DQLabs-Client.7za
7za x DQLabs-Airflow.7za
7za x site-packages.7za
wait $!
mv ~/.local/lib/python3.10/site-packages ~/.local/lib/python3.10/site-packages_bck
mv site-packages ~/.local/lib/python3.10/site-packages

#AIRFLOW Deployment
sudo apt-get install libmysqlclient-dev -y
#pip install pyopenssl --upgrade
#pip install pyarrow==6.0.1
#pip install pendulum==2.1.2
#pip install Flask-Session==0.5.0
#pip install connexion==2.14.2
#pip install python-dotenv
mkdir -p ~/airflow/dags
cd ~/airflow
export NODEJS_HOME=/home/$USER/node
export PM2_HOME=/home/$USER/node_modules/pm2/
export AIRFLOW_HOME=~/airflow
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/$USER/node/bin:/usr/local/spark/bin:/home/$USER/node_modules/pm2/bin
export NODEJS_HOME=/home/$USER/node
source ~/.bashrc
#pip install psycopg2-binary
pip uninstall apache-airflow-providers-fab -y
pip install apache-airflow==2.8.1
~/.local/bin/airflow db init
rm -rf airflow.cfg
wget https://s3.amazonaws.com/erwin-2.0/code/linux/airflow.cfg
sudo sed -i "s/ubuntu/$USER/g" /home/$USER/airflow/airflow.cfg
if [[ "$install_postgresql" == "yes" ]];
then
        CONNECTION_STRING="postgresql+psycopg2://$PG_USERNAME:$PG_PASSWORD@$PG_HOST:$PG_PORT_NO/$PG_DB_NAME"
        sudo sed -i "s|postgresql+psycopg2://airflow_user:airflowuser@localhost/airflow_db|$CONNECTION_STRING|g" airflow.cfg
else
        sudo sed -i "s/airflow_user:airflowuser/postgres:Intel1234/g" /home/$USER/airflow/airflow.cfg
fi
#pip uninstall apache-airflow-providers-fab -y
#pip uninstall apache-airflow-providers-postgres -y
#pip install apache-airflow-providers-postgres==5.13.0
#pip uninstall python-bidi -y
#pip install python-bidi==0.4.2
#pip uninstall apache-airflow-providers-fab -y
#pip uninstall apache-airflow -y
#pip install apache-airflow==2.8.1 
~/.local/bin/airflow db init
~/.local/bin/airflow users create --email support@dqlabs.ai --firstname dqlabs --lastname support --password admin --role Admin --username admin
sudo apt-get install build-essential libxml2-dev libxmlsec1-dev pkg-config -y
#pip install snowflake-sqlalchemy --upgrade
sudo wget https://s3.amazonaws.com/erwin-2.0/code/linux/airflow-scheduler.service -P /etc/systemd/system/
sudo wget https://s3.amazonaws.com/erwin-2.0/code/linux/airflow-webserver.service -P /etc/systemd/system/
sudo sed -i "s/ubuntu/$USER/g" /etc/systemd/system/airflow-webserver.service
sudo sed -i "s/ubuntu/$USER/g" /etc/systemd/system/airflow-scheduler.service
source ~/.bashrc
sudo systemctl enable airflow-webserver.service
sudo systemctl enable airflow-scheduler.service
sudo service airflow-webserver start
sudo service airflow-scheduler start
~/.local/bin/airflow version
#

if [[ "$port" == '80' || "$port" == '443' ]];then	
        echo "port=$port -------> machineip=$machineip"	
cd ~/DQLabs-Client/build/	
if [[ "$machineip" == 'private' ]]	
then	
        echo "Entering in private port 80 ---------------------->"	
        hostip=$(hostname -I | awk 'NR==1{print $1}' )	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000//g" {} \;	
elif [[ "$machineip" == 'public' ]]	
then	
        hostip=$(curl ifconfig.me)	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000//g" {} \;	
elif [ -z "$machineip" ]	
then	
        hostip=$DNSa	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000//g" {} \;	
else	
        echo "Updating port $port"	
fi	
else	
        echo "Updating port $port"	
fi	
if [[ "$port" != '80' || "$port" != '443' ]];then	
        echo "selected non standard http port"	
if [[ "$machineip" == 'private' ]]	
then	
        echo "Entering in private port $port ---------------------->"	
        hostip=$(hostname -I | awk 'NR==1{print $1}' )	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000/:$port/g" {} \;	
                sudo find /etc/apache2/sites-enabled/dqlabs.conf -exec sed -i "s/VirtualHost\ \*\:80/VirtualHost\ \*\:$port/g" {} \;	
                sudo find /etc/apache2/ports.conf -exec sed -i "s/80/$port/g" {} \;	
elif [[ "$machineip" == 'public'  ]]	
then	
        echo "Entering in public port $port ---------------------->"	
         hostip=$(curl ifconfig.me)	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000/:$port/g" {} \;	
                sudo find /etc/apache2/sites-enabled/dqlabs.conf -exec sed -i "s/VirtualHost\ \*\:80/VirtualHost\ \*\:$port/g" {} \;	
                sudo find /etc/apache2/ports.conf -exec sed -i "s/80/$port/g" {} \;	
elif [[  -z "$machineip"  ]]	
then	
        echo "Entering in DNS port 80 ---------------------->"	
        hostip=$DNSa	
        echo $hostip	
        echo $hostip	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/localhost/$hostip/g" {} \;	
        find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/:8000/:$port/g" {} \;	
else	
        echo "Localhost selected-------------------------------->>"	
         echo "Localhost selected-------------------------------->>"	
fi	
fi	
if [[ "$ssl" == "https" ]];	
then	
    hostip=$DNSa
    sudo sed -i "s|http://$hostip/api|https://$hostip/api|g" ~/DQLabs-Client/build/static/js/main.*
    find ~/DQLabs-Client/build/static/js/main.* -exec sed -i "s/http:\/\/\localhost/https:\/\/localhost/g" {} \;	
        else	
        echo "Its an non ssl site"	
        fi

cd ~/DQLabs-Client
sudo cp -rf build/* /var/www/html/.
export NODEJS_HOME=/home/$USER/node
export PM2_HOME=/home/$USER/node_modules/pm2/
export AIRFLOW_HOME=~/airflow
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/$USER/node/bin:/usr/local/spark/bin:/home/$USER/node_modules/pm2/bin
export NODEJS_HOME=/home/$USER/node
source ~/.bashrc
sudo apt install npm -y
sudo npm install pm2 -g

#####Server code

sudo wget https://s3.amazonaws.com/dqlabs2.0/pm2.service -P /etc/systemd/system/
sudo sed -i "s/ubuntu/$USER/g" /etc/systemd/system/pm2.service
sudo sed -i "s|/usr/bin/python3.10|$(which python3.10)|g" /etc/systemd/system/pm2.service
sudo systemctl enable pm2.service
sudo systemctl daemon-reload

cp -rf ~/DQLabs-Server/environments/onpremise.env ~/DQLabs-Server/src/dev.env
sed -i "s/localhost:8000/$hostip/g" ~/DQLabs-Server/src/dev.env
sed -i "s/SERVER_ENDPOINT=http/SERVER_ENDPOINT=$ssl/g" ~/DQLabs-Server/src/dev.env
if [ -n "$DNSa" ]; then
  sed -i "s|\[domain\].qa.dqlabsai.net|$DNSa|g" ~/DQLabs-Server/src/dev.env
fi

cp -rf ~/DQLabs-Server/src/dev.env ~/DQLabs-Server/src/.env
if [[ "$install_postgresql" == "yes" ]];
then
    sed -i "s/POSTGRESQL_HOST=localhost/POSTGRESQL_HOST=$PG_HOST/g" ~/DQLabs-Server/src/dev.env
    sed -i "s/POSTGRESQL_USER_NAME=postgres/POSTGRESQL_USER_NAME=$PG_USERNAME/g" ~/DQLabs-Server/src/dev.env
    sed -i "s/POSTGRESQL_PASSWORD=Intel1234/POSTGRESQL_PASSWORD=$PG_PASSWORD/g" ~/DQLabs-Server/src/dev.env
    sed -i "s/POSTGRESQL_DB_NAME=dqlabs/POSTGRESQL_DB_NAME=$PG_DB_NAME/g" ~/DQLabs-Server/src/dev.env
    sed -i "s/POSTGRESQL_PORT=5432/POSTGRESQL_PORT=$PG_PORT_NO/g" ~/DQLabs-Server/src/dev.env
    cp -rf ~/DQLabs-Server/src/dev.env ~/DQLabs-Server/src/.env
fi
cd ~/DQLabs-Server/src
sed -i "s/admin@dqlabs.ai/$username/g" ~/DQLabs-Server/src/default_data/users.json
sed -i "s/DQl@bs@dm1n/$password/g" ~/DQLabs-Server/src/default_data/users.json
sed -i "s/admin@dqlabs.ai/$username/g" ~/DQLabs-Server/src/default_data/organizations.json

#pip install -r requirements.txt --no-warn-script-location
python3.10 manage.py init_servers
sleep 20
python3.10 manage.py update_release --client $VERSION --server $VERSION --airflow $VERSION
python3.10 manage.py update_brandlabel --copyright "Licensed to erwin by Quest" --title Erwin --primarycolor "#10213B"
mkdir ~/migration_files
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
cp -rf core/migrations ~/migration_files/"$CURRENT_DATE"
cp -rf core/migrations ~/migration_files/latest
sed -i "s/ec2-user/$USER/g" start.json
sudo systemctl enable pm2.service
sudo service pm2 start

##########Airflow code
echo "############### apache-airflow-providers-jdbc ##############"
pip install apache-airflow-providers-jdbc==3.3.0
pip install pymssql==2.3.0
pip install apache-airflow-providers-microsoft-mssql==3.6.0

cp ~/DQLabs-Airflow/infra/airflow/dags/environments/onpremise.env ~/DQLabs-Airflow/infra/airflow/dags/.env

if [[ "$install_postgresql" == "yes" ]];
then
        sed -i "s/DQLABS_POSTGRES_HOST=localhost/DQLABS_POSTGRES_HOST=$PG_HOST/g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s/DQLABS_POSTGRES_USER=postgres/DQLABS_POSTGRES_USER=$PG_USERNAME/g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s/DQLABS_POSTGRES_PASSWORD=Intel1234/DQLABS_POSTGRES_PASSWORD=$PG_PASSWORD/g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s/DQLABS_POSTGRES_DB=dqlabs/DQLABS_POSTGRES_DB=$PG_DB_NAME/g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s/DQLABS_POSTGRES_PORT=5432/DQLABS_POSTGRES_PORT=$PG_PORT_NO/g" ~/DQLabs-Airflow/infra/airflow/dags/.env
fi
if [[ "$ssl" == "https" ]];
       then
    hostip=$DNSa
        sed -i "s|DQLABS_SERVER_ENDPOINT=http:\/\/localhost|DQLABS_SERVER_ENDPOINT=https:\/\/$hostip|g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s|DQLABS_CLIENT_ENDPOINT=http:\/\/localhost|DQLABS_CLIENT_ENDPOINT=https:\/\/$hostip|g" ~/DQLabs-Airflow/infra/airflow/dags/.env
    else
        sed -i "s|DQLABS_SERVER_ENDPOINT=http:\/\/localhost|DQLABS_SERVER_ENDPOINT=https:\/\/$hostip|g" ~/DQLabs-Airflow/infra/airflow/dags/.env
        sed -i "s|DQLABS_CLIENT_ENDPOINT=http:\/\/localhost|DQLABS_CLIENT_ENDPOINT=https:\/\/$hostip|g" ~/DQLabs-Airflow/infra/airflow/dags/.env
fi
cd ~/DQLabs-Airflow/infra/airflow/
#mv mwaa_requirements_2.8.1.txt requirements.txt
#sed -i 's/--find-links \/usr\/local\/airflow\/plugins/#--find-links \/usr\/local\/airflow\/plugins/g' requirements.txt
cd ~/DQLabs-Airflow/infra/airflow/dags/
rm -rf requirements.txt
touch  ~/DQLabs-Airflow/infra/airflow/dags/requirements.txt
sed -i "s/# //g" setup.py
#pip install pkutils==3.0.2
#pip install packaging==22
#pip uninstall setuptools -y
#pip install setuptools==69.5.1
#pip install --upgrade pip
python3.10 setup.py bdist_wheel
pip install dist/dqlabs-2.0-py3-none-any.whl --force-reinstall --no-warn-script-location
cp ~/DQLabs-Airflow/infra/airflow/dags/*.py ~/airflow/dags/.
rm -rf ~/airflow/dags/setup.py
#pip install pyarrow==6.0.0
sudo mkdir -p /usr/local/airflow/plugins/driver/jdbc/
sudo mkdir -p /usr/local/airflow/plugins/driver/odbc/
sudo chown -R $USER.$USER /usr/local/airflow
cp ~/DQLabs-Airflow/infra/airflow/jars/*.jar /usr/local/airflow/plugins/driver/jdbc/.
sudo cp ~/DQLabs-Airflow/infra/airflow/jars/*.jar /usr/lib/.
sudo chmod 777 /usr/lib/*.jar
cp ~/DQLabs-Airflow/infra/airflow/jars/denodo-vdp-odbcdriver-linux.tar.gz /usr/local/airflow/plugins/driver/odbc/
cd  /usr/local/airflow/plugins/driver/odbc/
tar -xvf denodo-vdp-odbcdriver-linux.tar.gz
sudo echo "[DenodoODBCDriver]" >~/odbc.ini
sudo echo "Description=ODBC driver of Denodo" >>~/odbc.ini
sudo echo "Driver=/usr/local/airflow/plugins/driver/odbc/denodo-vdp-odbcdriver-linux/lib/unixodbc_x64/denodoodbc.so" >>~/odbc.ini
sudo echo "UsageCount=1" >>~/odbc.ini
sudo cp -rf ~/odbc.ini /etc/
source ~/.bashrc
#pip install pendulum~=2.0.0
#pip install Flask-Session==0.5.0
#pip uninstall apache-airflow -y
#pip install apache-airflow==2.8.1
#pip uninstall apache-airflow-providers-fab -y
#ip uninstall apache-airflow-providers-postgres -y
#pip install apache-airflow-providers-postgres==5.13.0
#pip uninstall python-bidi -y
#pip install python-bidi==0.4.2
#~/.local/bin/airflow db init
#~/.local/bin/airflow users create --email support@dqlabs.ai --firstname dqlabs --lastname support --password admin --role Admin --username admin
#~/.local/bin/airflow db upgrade
source ~/.bashrc
sudo systemctl enable pm2
sudo systemctl enable airflow-webserver
sudo systemctl enable airflow-scheduler
sudo service pm2 restart
sudo service airflow-webserver restart
sudo service airflow-scheduler restart
sudo service apache2 restart
cd ~/