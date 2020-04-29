using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO.Ports;
using System.Threading;
namespace DisplayComunicacionSerie
{
    public partial class Form1 : Form
    {
        private Byte[] rcvedMessage;
        private Thread readThread;
        private int rcvedLength;
        string message;
        private SerialPort port;
        public Form1()
        {
            InitializeComponent();
        }

        private void Connect_Click(object sender, EventArgs e)
        {
            if (COMPORT.SelectedItem != null && BaudRate.SelectedItem!=null)
            {
                int baudRate =int.Parse( BaudRate.SelectedItem.ToString());
                string comPort = COMPORT.SelectedItem.ToString();
                port = new SerialPort(comPort,baudRate, Parity.None, 8, StopBits.One);
                Console.WriteLine("El puerto serie {0} se ha creado",comPort);
                rcvedMessage = new Byte[port.ReadBufferSize];
                port.Open();
                readThread.Start();
                Console.WriteLine(port.BytesToRead);
                MsgRec.Visible = true;
                label3.Visible = true;
                Connect.Enabled = false;
                Connect.Visible = false;
            }
            else
            {
                Console.WriteLine("Error no se ha seleccionado alguna opcion para conectar");
            }
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            foreach (string s in SerialPort.GetPortNames())
            {
                COMPORT.Items.Add(s);
            }
            COMPORT.SelectedIndex = 2;
            BaudRate.SelectedIndex = 0;
            readThread = new Thread(Read);
        }
        private void WriteMessage(string msg)
        {
            if (InvokeRequired)
            {
                this.Invoke(new Action<string>(WriteMessage), new object[] { msg });
                return;
            }
            MsgRec.Text += msg.Replace("\r", "\r\n"); ;
        }
        private void Read()
        {
            while (true)
            {
                try
                {
                    message = port.ReadLine();
                    WriteMessage(message);
                }
                catch (TimeoutException) { }
            }
        }

    }
    
}

