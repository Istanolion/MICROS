namespace DisplayComunicacionSerie
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.COMPORT = new System.Windows.Forms.ComboBox();
            this.Connect = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.BaudRate = new System.Windows.Forms.ComboBox();
            this.MsgRec = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.Close = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(32, 69);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(65, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Puerto Serie";
            // 
            // COMPORT
            // 
            this.COMPORT.FormattingEnabled = true;
            this.COMPORT.Location = new System.Drawing.Point(122, 66);
            this.COMPORT.Name = "COMPORT";
            this.COMPORT.Size = new System.Drawing.Size(121, 21);
            this.COMPORT.TabIndex = 3;
            // 
            // Connect
            // 
            this.Connect.Location = new System.Drawing.Point(141, 167);
            this.Connect.Name = "Connect";
            this.Connect.Size = new System.Drawing.Size(75, 23);
            this.Connect.TabIndex = 4;
            this.Connect.Text = "Connect";
            this.Connect.UseVisualStyleBackColor = true;
            this.Connect.Click += new System.EventHandler(this.Connect_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(32, 114);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(58, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Baud Rate";
            // 
            // BaudRate
            // 
            this.BaudRate.FormattingEnabled = true;
            this.BaudRate.Items.AddRange(new object[] {
            "9600",
            "19200",
            "38400"});
            this.BaudRate.Location = new System.Drawing.Point(122, 111);
            this.BaudRate.Name = "BaudRate";
            this.BaudRate.Size = new System.Drawing.Size(121, 21);
            this.BaudRate.TabIndex = 6;
            // 
            // MsgRec
            // 
            this.MsgRec.AcceptsTab = true;
            this.MsgRec.Location = new System.Drawing.Point(35, 281);
            this.MsgRec.Multiline = true;
            this.MsgRec.Name = "MsgRec";
            this.MsgRec.ReadOnly = true;
            this.MsgRec.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.MsgRec.Size = new System.Drawing.Size(303, 141);
            this.MsgRec.TabIndex = 7;
            this.MsgRec.Visible = false;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(138, 246);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(102, 13);
            this.label3.TabIndex = 8;
            this.label3.Text = "Mensajes Recibidos";
            this.label3.Visible = false;
            // 
            // Close
            // 
            this.Close.Enabled = false;
            this.Close.Location = new System.Drawing.Point(141, 210);
            this.Close.Name = "Close";
            this.Close.Size = new System.Drawing.Size(75, 23);
            this.Close.TabIndex = 9;
            this.Close.Text = "CLOSE";
            this.Close.UseVisualStyleBackColor = true;
            this.Close.Visible = false;
            this.Close.Click += new System.EventHandler(this.Close_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ControlDark;
            this.ClientSize = new System.Drawing.Size(362, 450);
            this.Controls.Add(this.Close);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.MsgRec);
            this.Controls.Add(this.BaudRate);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.Connect);
            this.Controls.Add(this.COMPORT);
            this.Controls.Add(this.label1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox COMPORT;
        private System.Windows.Forms.Button Connect;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox BaudRate;
        private System.Windows.Forms.TextBox MsgRec;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button Close;
    }
}

