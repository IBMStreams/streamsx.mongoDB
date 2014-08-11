
package Insert_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   	use File::Basename qw(dirname);
   	use InsertCommon;
   	
   	unshift @INC, dirname($model->getContext()->getOperatorDirectory()) . '/Common';
   	require BSONCommon;
   
   	my $dbHost = $model->getParameterByName('dbHost')->getValueAt(0)->getCppExpression();
   	my $dbPort = ($_ = $model->getParameterByName('dbPort')) ? $_->getValueAt(0)->getCppExpression() : 27017;
   	my $timeout = ($_ = $model->getParameterByName('timeout')) ? $_->getValueAt(0)->getCppExpression() : 0.0;
   print "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildConnUrl(const string& dbHost, uint32_t dbPort) {', "\n";
   print '	string connUrl = dbHost;', "\n";
   print '	connUrl += ":"; ', "\n";
   print '	connUrl += spl_cast<rstring,uint32_t>::cast(dbPort);', "\n";
   print '	return connUrl;', "\n";
   print '}', "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildDbCollection(const string& db, const string& collection) {', "\n";
   print '	string dbCollection(db);', "\n";
   print '	dbCollection += ".";', "\n";
   print '	dbCollection += collection;', "\n";
   print '	return dbCollection;', "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR() {', "\n";
   print '	try {', "\n";
   print '		ScopedDbConnection conn(buildConnUrl(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print '), (double)';
   print $timeout;
   print ');', "\n";
   print '		if(!conn.ok()) {', "\n";
   print '			THROW(SPL::SPLRuntimeOperator, "MongoDB create connection failed");', "\n";
   print '		}', "\n";
   print '		conn.done();', "\n";
   print '	}', "\n";
   print '	catch( const DBException &e ) {', "\n";
   print '		THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady() {}', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port) {', "\n";
   print '	';
   	my $numberOfInputPorts = $model->getNumberOfInputPorts();
   	for (my $i = 0; $i < $numberOfInputPorts; $i++) {
   print "\n";
   print '	  IPort';
   print $i;
   print 'Type const & ';
   print $model->getInputPortAt($i)->getCppTupleName();
   print ' = static_cast<IPort';
   print $i;
   print 'Type const&>(tuple);', "\n";
   print '	';
   }
   print "\n";
   print '	streams_boost::shared_ptr<OPort0Type> otuplePtr;', "\n";
   print '	bool errorFound = false;', "\n";
   print "\n";
   # [----- perl code -----]
   	foreach my $attribute (@{$model->getOutputPortAt(0)->getAttributes()}) {
   	  my $name = $attribute->getName();
   	  if ($attribute->hasAssignmentWithOutputFunction()) {
   		  my $operation = $attribute->getAssignmentOutputFunctionName();
   		  if ($operation eq 'AsIs') {
   			my $init = $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   		  
   print "\n";
   print '			otuplePtr->set_';
   print $name;
   print '(';
   print $init;
   print ');', "\n";
   print '		  ';
   }
   		  else {
   			my $numberOfParams = @{$attribute->getAssignmentOutputFunctionParameterValues};
   			my $shift = $numberOfParams > 4 ? 2 : 0;
   			my $expr;
   			my $key = '';
   			my $keyAssigned = $numberOfParams == 4 || $numberOfParams == 6;
   			if ($keyAssigned) {
   				$key = $attribute->getAssignmentOutputFunctionParameterValueAt(2+$shift)->getCppExpression();
   				$expr = $attribute->getAssignmentOutputFunctionParameterValueAt(3+$shift);
   			}
   			else {
   				$expr = $attribute->getAssignmentOutputFunctionParameterValueAt(2+$shift);
   				if (InsertCommon::keyLess($expr->getSPLType())) {
   					SPL::CodeGen::errorln("The type '%s' of the expression '%s' requires additional key parameter.", $expr->getSPLType(), $expr->getSPLExpression(), $expr->getSourceLocation());
   				}
   			}
   			my $exprLocation = $expr->getSourceLocation();
   			my $cppExpr = $expr->getCppExpression();
   			my $splType = $expr->getSPLType();
   			
   			if ($numberOfInputPorts > 1 && $expr->hasStreamAttributes()) {
   				my $portNumber = -1;
   				for (my $i = 0; $i < $numberOfInputPorts; $i++) {
   					if (index($cppExpr, $model->getInputPortAt($i)->getCppTupleName()) != -1) {
   						if ($portNumber != -1) {
   							SPL::CodeGen::errorln("Multiple input ports attributes in expression '%s' are used.", $expr->getSPLExpression(), $expr->getSourceLocation());
   						}
   						else {
   							$portNumber = $i;
   						}
   					}
   				}
   print "\n";
   print '		if(port == ';
   print $portNumber;
   print ')', "\n";
   print '			';
   }
   print "\n";
   print '		{', "\n";
   print '		', "\n";
   # [----- perl code -----]
   			InsertCommon::buildBSONObjectWithKey($exprLocation, $key, $cppExpr, $splType);
   			
   			my $currentDbHost = $numberOfParams > 4 ? $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression()  : $dbHost;
   			my $currentDbPort = $numberOfParams > 4 ? $attribute->getAssignmentOutputFunctionParameterValueAt(1)->getCppExpression()  : $dbPort;
   			my $db = $attribute->getAssignmentOutputFunctionParameterValueAt(0+$shift)->getCppExpression();
   			my $collection = $attribute->getAssignmentOutputFunctionParameterValueAt(1+$shift)->getCppExpression();
   # [----- perl code -----]
   print "\n";
   print '			', "\n";
   print '			rstring errorMsg = "";', "\n";
   print '			try {', "\n";
   print '				ScopedDbConnection conn(buildConnUrl(';
   print $currentDbHost;
   print ', ';
   print $currentDbPort;
   print '), (double)';
   print $timeout;
   print ');', "\n";
   print '				', "\n";
   print '				if(conn.ok()) {', "\n";
   print '					conn->insert(buildDbCollection(';
   print $db;
   print ', ';
   print $collection;
   print '), b0.obj());', "\n";
   print '					errorMsg = conn->DBClientWithCommands::getLastError();', "\n";
   print '					conn.done();', "\n";
   print '				}', "\n";
   print '				else {', "\n";
   print '					errorMsg = "MongoDB create connection failed";', "\n";
   print '				}', "\n";
   print '			}', "\n";
   print '			catch( const DBException &e ) {', "\n";
   print '				errorMsg = e.what();', "\n";
   print '			}', "\n";
   print '			', "\n";
   print '			if (errorMsg != "") {', "\n";
   print '				errorFound = true;', "\n";
   print '				SPLAPPLOG(L_ERROR, error, "MongoDB Insert");', "\n";
   print '				if(!otuplePtr){', "\n";
   print '					otuplePtr = streams_boost::shared_ptr<OPort0Type>(new OPort0Type());', "\n";
   print '				}', "\n";
   print '				otuplePtr->set_';
   print $name;
   print '(errorMsg);', "\n";
   print '			}', "\n";
   print '		}', "\n";
   print '		  ';
   }
   	  }
   	}
   print "\n";
   print '	if(errorFound) submit(*otuplePtr, 0);', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
