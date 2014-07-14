
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
   #	use Data::Dumper;
   	use InsertCommon;
   
   	my $dbHost = $model->getParameterByName('dbHost')->getValueAt(0)->getCppExpression();
   	my $dbPortParam = $model->getParameterByName('dbPort');
   	
   	my $autoReconnectParam = $model->getParameterByName('autoReconnect');
   	my $autoReconnect = (defined $autoReconnectParam) ? $autoReconnectParam->getValueAt(0)->getCppExpression() : 'true';
   	
   	my $timeoutParam = $model->getParameterByName('timeout');
   	my $timeout = (defined $timeoutParam) ? $timeoutParam->getValueAt(0)->getCppExpression() : 0;
   
   	my $inputPort = $model->getInputPortAt(0);
   	my $outputPort = $model->getOutputPortAt(0);
   	my $inTuple = $inputPort->getCppTupleName();
   print "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR() : conn_(';
   print $autoReconnect;
   print ', NULL, ';
   print $timeout;
   print ') {', "\n";
   print '	try {', "\n";
   print '		string connUrl = ';
   print $dbHost;
   print ';', "\n";
   print '		';
   if (defined $dbPortParam) {
   		  my $dbPort = $dbPortParam->getValueAt(0)->getCppExpression();
   print "\n";
   print '		  connUrl += ":"; ', "\n";
   print '		  connUrl += spl_cast<rstring,uint32_t>::cast(';
   print $dbPort;
   print ');', "\n";
   print '		';
   }
   print ' ', "\n";
   print '		conn_.connect(connUrl);', "\n";
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
   print '	IPort0Type const & ';
   print $inTuple;
   print ' = static_cast<IPort0Type const&>(tuple);', "\n";
   print '	streams_boost::shared_ptr<OPort0Type> otuplePtr;', "\n";
   print '	bool errorFound = false;', "\n";
   print "\n";
   print '	';
    foreach my $attribute (@{$outputPort->getAttributes()}) {
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
   			
   print "\n";
   print '		{', "\n";
   print '			string dbCollection(';
   print $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   print ');', "\n";
   print '			dbCollection += ".";', "\n";
   print '			dbCollection += ';
   print $attribute->getAssignmentOutputFunctionParameterValueAt(1)->getCppExpression();
   print ';', "\n";
   print '			';
   			my $expr = $attribute->getAssignmentOutputFunctionParameterValueAt(2);
   			my $key = 'defaultKey';
   			my $keyAssigned = @{$attribute->getAssignmentOutputFunctionParameterValues} > 3;
   			if ($keyAssigned) {
   				$key = $attribute->getAssignmentOutputFunctionParameterValueAt(2)->getCppExpression();
   				$expr = $attribute->getAssignmentOutputFunctionParameterValueAt(3);
   			}
   			my $exprLocation = $expr->getSourceLocation();
   			my $cppExpr = $expr->getCppExpression();
   			my $splType = $expr->getSPLType();
   			
   			if ($keyAssigned) {
   				if (SPL::CodeGen::Type::isPrimitive($splType)) {
   					my $value = InsertCommon::handlePrimitive($exprLocation, $cppExpr, $splType);
   print "\n";
   print '					BSONObjBuilder b0;', "\n";
   print '					b0.append(';
   print $key;
   print ', ';
   print $value;
   print '); ', "\n";
   print '				';
   }
   				else {
   					my ($appendFunction,$objFunction) = InsertCommon::buildBSONObject($model, $exprLocation, $cppExpr, $splType, 1);
   print "\n";
   print '					BSONObjBuilder b0;', "\n";
   print '					b0.';
   print $appendFunction;
   print '(';
   print $key;
   print ', b1.';
   print $objFunction;
   print '());', "\n";
   print '				';
   }
   			}
   			else {
   				if (InsertCommon::keyLess($splType)) {
   					SPL::CodeGen::errorln("The type '%s' of the expression '%s' requires additional key parameter.", $splType, $expr->getSPLExpression(), $exprLocation) unless ($keyAssigned);
   				}
   				InsertCommon::buildBSONObject($model, $exprLocation, $cppExpr, $splType, 0);
   			}
   			
   print "\n";
   print '			conn_.insert(dbCollection, b0.obj());', "\n";
   print '			const rstring errorMsg = conn_.DBClientWithCommands::getLastError();', "\n";
   print '			if (errorMsg != "") {', "\n";
   print '				errorFound = true;', "\n";
   print '				SPLAPPLOG(L_ERROR, error, "MongoDBInsert");', "\n";
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
