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
        private bool _continue;
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
                readThread = new Thread(Read);
                int baudRate =int.Parse( BaudRate.SelectedItem.ToString());
                string comPort = COMPORT.SelectedItem.ToString();
                port = new SerialPort(comPort,baudRate, Parity.None, 8, StopBits.One);
                Console.WriteLine("El puerto serie {0} se ha creado",comPort);
                rcvedMessage = new Byte[port.ReadBufferSize];
                port.Open();
                _continue = true;
                readThread.Start();
                Console.WriteLine(port.BytesToRead);
                MsgRec.Visible = true;
                label3.Visible = true;
                Connect.Enabled = false;
                Connect.Visible = false;
                Close.Enabled = true;
                Close.Visible = true;
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
            while (_continue)
            {
                try
                {
                    message = port.ReadLine();
                    WriteMessage(message);
                }
                catch (ThreadInterruptedException e) { }
                catch (System.IO.IOException) { }
            }
        }

        private void Close_Click(object sender, EventArgs e)
        {
            _continue = false;
            port.Close();
            MsgRec.Visible = false;
            label3.Visible = false;
            Connect.Enabled = true;
            Connect.Visible = true;
            Close.Enabled = false;
            Close.Visible = false;
            MsgRec.ResetText();
        }
    }
    
}

