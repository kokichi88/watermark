package gui 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import org.aswing.ASColor;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	import org.aswing.geom.IntDimension;
	import org.aswing.GridLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JTextArea;
	import org.aswing.JTextField;
	/**
	 * ...
	 * @author ...
	 */
	public class View 
	{
		static public var mainFrame:JFrame;
		static public var mainPanel:JPanel;
		static public var leftPanel:JPanel;
		static public var rightPanel:JPanel;		
		
		static public var serverPanel:JPanel;
		static public var generalPanel:JPanel;
		static public var paramPanel:JPanel;
		static public var userPanel:JPanel;
		static public var snapshotPanel:JPanel;
		
		static public var paramOne:JTextField;
		static public var paramTwo:JTextField;
		static public var paramThree:JTextField;
		static public var paramFour:JTextField;
		
		static public var txMsg : JTextArea = new JTextArea("Message Here");
		
		static private var stageWidth:int = 1024;
		static private var stageHeight:int = 400;
		
		public function View() 
		{
			
		}
		
		public function init(root:Sprite):void
		{
			mainFrame = new JFrame(root, "Watermark");				
			mainFrame.getContentPane().append(createMainPanel());
			mainPanel.append(createLeftPanel());
			mainPanel.append(createRightPanel());			
			mainFrame.setSize(new IntDimension(stageWidth,stageHeight));
			mainFrame.show();	
			
			addControlPanel();
			
			addResultPanel();
			
			addComponent();
		}
		
		private function addComponent():void 
		{
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_LOAD_WATERMARK);
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_LOAD_IMAGE);
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_SAVE_PATH);
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_OFFSET);
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_COMPRESS);
			addButton(generalPanel, Controller.onButtonPress, Controller.BT_HMTL_LOAD);
			
		
			
			paramOne = addTextBox(paramPanel, "Param 1","");
			paramTwo = addTextBox(paramPanel, "Param 2","");
			paramThree = addTextBox(paramPanel, "Param 3","");
			paramFour = addTextBox(paramPanel, "Param 4","");
		}
		
		public static function addButton(toPanel:JPanel, callBack: Function, btName:String, tooltip:String=""):void
		{
			var bt:JButton = new JButton(btName);
			bt.setName(btName);		
			bt.setToolTipText(btName);
			toPanel.append(bt);				
			bt.addActionListener(callBack);
		}
		
		public static function addTextBox(toPanel:JPanel, txName:String, txValue:String):JTextField
		{
			var lb:JLabel = new JLabel(txName);
			toPanel.append(lb);
			var tx:JTextField = new JTextField();
			tx.setName(txName);
			toPanel.append(tx);
			tx.setText(txValue);
			return tx;
		}
		
		private function addResultPanel():void 
		{
			createResultPanel(txMsg,   2, "Message");
		}
		
		private function createResultPanel(txArea: JTextArea, index:int, label: String = ""):void 
		{
			var locX: Array  = new Array(20,  20,  20);
			var locY: Array  = new Array(20,  80,  20);
			var sizeX: Array = new Array(600, 600, 600);
			var sizeY: Array = new Array(30,  40,  620);
			
			var lb: JLabel = new JLabel(label);
			rightPanel.append(lb);
			txArea.setLocationXY(locX[index], locY[index]);
			txArea.setSizeWH(sizeX[index], sizeY[index]);
			txArea.setBorder(new LineBorder());
			rightPanel.addChild(txArea);
		}
		
		private function addControlPanel():void 
		{
			generalPanel = new JPanel();
			generalPanel.setBorder(new LineBorder());
			generalPanel.setLayout(new GridLayout(0,4));
			leftPanel.append(generalPanel);
			
			paramPanel = new JPanel();
			paramPanel.setBorder(new LineBorder());
			paramPanel.setLayout(new GridLayout(0,2));
			leftPanel.append(paramPanel);
		}
		
		private function createRightPanel():JPanel 
		{
			//rightPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
			rightPanel = new JPanel(new VerticalLayout(10, 40));
			rightPanel.setBorder(new LineBorder(null, new ASColor(0x000000, 1)));
			rightPanel.setSizeWH(stageWidth / 2, stageHeight);
			rightPanel.setLocationXY(stageWidth / 2, 0);
			return rightPanel;
		}
		
		private function createLeftPanel():JPanel 
		{
			leftPanel = new JPanel();
			var maxR:int = 0;
			var maxC:int = 1;
			leftPanel.setBorder(new LineBorder(null, new ASColor(0x000000, 1)));
			leftPanel.setLayout(new GridLayout(maxR, maxC, 10, 10));
			leftPanel.setSizeWH(stageWidth / 2, stageHeight);
			return leftPanel;
		}
		
		private function createMainPanel():JPanel 
		{
			mainPanel = new JPanel(new GridLayout());
			return mainPanel;
		}
		
	}

}